# Unify System Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fold the separate chezmoi dotfiles repository into `/etc/nix-darwin` and deliver all user configuration through standalone Home Manager, keeping dotfile edits instant and stopping `darwin-rebuild switch` from uninstalling Homebrew packages.

**Architecture:** Dotfiles become plain files under `home/dotfiles/`, delivered two ways from one source: out-of-store symlinks into the live repo on workstations (instant edits), and Nix store copies on the Linux VMs (hermetic). Home Manager is wired as standalone `homeConfigurations` on Darwin — not a darwin module — so `home-manager switch` handles user packages and dotfiles without sudo, while `darwin-rebuild switch` is reserved for system state.

**Tech Stack:** Nix flakes, nix-darwin 26.05, home-manager 26.05, jj (Jujutsu), Homebrew, macOS launchd.

Spec: `docs/superpowers/specs/2026-08-27-unify-system-config-design.md`

## Global Constraints

- **Version control is `jj`, never raw `git`.** Every commit step uses `jj describe -m "..."` followed by `jj new`. `jj git push` is permitted; `git commit`/`git add` are not.
- Nix formatting is `alejandra`. Run `nix fmt` before every commit that touches `.nix` files.
- `nix flake check --no-build` must pass before any commit that changes flake
  evaluation. **Use `--no-build` on `io`.** Bare `nix flake check` tries to
  *build* the two `aarch64-linux` NixOS configurations, and `io` has no local
  Linux builder — it offloads to `oberon`'s rosetta-builder over the tailnet,
  which is currently refusing connections. That failure is environmental and
  predates this work; it is not a signal about your change.
- `darwin-rebuild build --flake .#<hostname>` must succeed before any commit that changes a Darwin system configuration.
- Home Manager release is `release-26.05`, matching `nixpkgs` (`nixos-26.05`). Do not mix releases.
- `home.stateVersion` is `"26.05"` on all hosts. Never change an existing `stateVersion`.
- Repo root on every workstation is `/etc/nix-darwin`. Out-of-store symlinks resolve against it.
- Hosts: Darwin `io`, `oberon`, `andon` (andon has `isVibium = true`); NixOS `nixos-vm`, `agent-vm`.
- Identity: `paulsmith@pobox.com` everywhere except `andon`, which uses `paul@vibium.com`.
- Never delete `ssh://bunny/media/nas/repo/dotfiles.git`. It is the rollback path.
- A warm `darwin-rebuild build` is ~2s. If a build takes minutes, a flake input moved and is rebuilding from source — that is expected, not a failure.

---

### Task 1: Reconcile the forked dotfiles repository

The chezmoi repo has two divergent remotes. Everything downstream needs one unambiguous tree.

**Files:**
- Modify: `/Users/paul/.local/share/chezmoi/dot_bashrc`
- Modify: `/Users/paul/.local/share/chezmoi/dot_claude/settings.json`
- Modify: `/Users/paul/.local/share/chezmoi/dot_config/nvim/lazy-lock.json`

**Interfaces:**
- Consumes: nothing.
- Produces: a single reconciled tree at `/Users/paul/.local/share/chezmoi` whose `main` contains both forks' work. Task 3 copies from it.

- [ ] **Step 1: Record the three divergent revisions**

```bash
cd /Users/paul/.local/share/chezmoi
jj log -r 'main' --no-pager -T 'commit_id ++ "\n"'
git ls-remote git@github.com:paulsmith/dotfiles.git main
git ls-remote ssh://bunny/media/nas/repo/dotfiles.git main
```

Expected: local/bunny at `3c33dd1d`, GitHub at `b453a705`. Merge base is `dde1191c`.

- [ ] **Step 2: Verify the settings.json defect before touching anything**

```bash
jq empty /Users/paul/.local/share/chezmoi/dot_claude/settings.json
```

Expected: FAIL — `jq: parse error: Expected separator between values at line 25, column 10`.

```bash
jq empty ~/.claude/settings.json
```

Expected: PASS. The live file is valid; the source copy is not. The live file wins.

- [ ] **Step 3: Fetch the GitHub fork into the local repo**

```bash
cd /Users/paul/.local/share/chezmoi
jj git remote add github git@github.com:paulsmith/dotfiles.git
jj git fetch --remote github
jj log -r 'main | main@github' --no-pager
```

The remote-tracking revset is `main@github` — the bookmark name followed by the
remote name, not the remote name twice.

Expected: both heads visible, diverged from `dde1191c`.

- [ ] **Step 4: Merge the two heads**

```bash
cd /Users/paul/.local/share/chezmoi
jj new main github@github -m "Reconcile dotfiles fork between bunny and GitHub"
jj status
```

Expected: a merge revision with conflicts in `dot_bashrc`, `dot_config/nvim/lazy-lock.json`, and `run_onchange_before_install-packages-darwin.sh.tmpl`.

- [ ] **Step 5: Resolve the bashrc conflict**

Both sides fixed the same pnpm bug differently. Replace the entire `# pnpm` block at the end of `dot_bashrc` with the portable form (`$HOME`, prepend ordering):

```bash
# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
```

- [ ] **Step 6: Resolve the remaining two conflicts**

`jj resolve --tool` invokes an *external* 3-way merge tool; there is no
built-in `:ours`. Resolve these by writing the file directly — jj treats a file
with no conflict markers as resolved.

`run_onchange_before_install-packages-darwin.sh.tmpl` is deleted by Task 8, so
its content does not matter. Take the bunny side verbatim:

Note: only two conflicts may actually materialise — the `.tmpl` file often
merges cleanly, since each fork only deleted distinct lines from it. Resolve
whichever ones jj reports; leave a clean merge alone.

```bash
cd /Users/paul/.local/share/chezmoi
jj file show -r main@bunny run_onchange_before_install-packages-darwin.sh.tmpl \
  > run_onchange_before_install-packages-darwin.sh.tmpl
```

`lazy-lock.json` is regenerated in Step 8, so its content does not matter
either:

```bash
jj file show -r main@bunny dot_config/nvim/lazy-lock.json \
  > dot_config/nvim/lazy-lock.json
```

Confirm neither file still carries conflict markers:

```bash
grep -l '^<<<<<<<' run_onchange_before_install-packages-darwin.sh.tmpl \
  dot_config/nvim/lazy-lock.json 2>/dev/null && echo "STILL CONFLICTED" || echo "RESOLVED"
```

Expected: `RESOLVED`.

- [ ] **Step 7: Replace the broken settings.json with the valid live copy**

```bash
cp ~/.claude/settings.json /Users/paul/.local/share/chezmoi/dot_claude/settings.json
jq empty /Users/paul/.local/share/chezmoi/dot_claude/settings.json && echo VALID
```

Expected: `VALID`.

- [ ] **Step 8: Regenerate lazy-lock.json**

```bash
nvim --headless "+Lazy! sync" +qa
cp ~/.config/nvim/lazy-lock.json /Users/paul/.local/share/chezmoi/dot_config/nvim/lazy-lock.json
jq empty /Users/paul/.local/share/chezmoi/dot_config/nvim/lazy-lock.json && echo VALID
```

Expected: `VALID`.

- [ ] **Step 9: Verify the merge is clean and bashrc parses**

```bash
cd /Users/paul/.local/share/chezmoi
jj status
bash -n dot_bashrc && echo "bashrc syntax OK"
```

Expected: no unresolved conflicts; `bashrc syntax OK`.

- [ ] **Step 10: Commit the reconciliation**

```bash
cd /Users/paul/.local/share/chezmoi
jj describe -m "Reconcile dotfiles fork between bunny and GitHub

Both remotes independently fixed the same pnpm PATH bug; resolved to the
portable \$HOME form with prepend ordering. Replaced the source copy of
.claude/settings.json, which was invalid JSON, with the valid live file.
Regenerated lazy-lock.json."
jj new
jj bookmark set main -r @-
```

---

### Task 2: Audit the dotfiles for secrets

This is the gate on publishing into a public repository. If anything sensitive turns up, stop and escalate before Task 3.

**Files:**
- Create: `docs/superpowers/plans/2026-08-27-secret-audit.md` (findings record)

**Interfaces:**
- Consumes: the reconciled tree from Task 1.
- Produces: a go/no-go decision recorded in the audit file.

- [ ] **Step 1: Enumerate every file to be audited**

```bash
cd /Users/paul/.local/share/chezmoi
find . -path ./.git -prune -o -path ./.jj -prune -o -type f -print | sort
```

Expected: 43 files after the Task 1 merge.

**39 of those are in scope** — the 38 that Task 3 copies into the public repo,
plus `run_onchange_before_install-packages-darwin.sh.tmpl`, whose contents are
transcribed into the Homebrew module in Task 6.

Four are out of scope because nothing copies them: `.chezmoiignore`,
`AGENTS.md`, `CLAUDE.md`, `README.md`. Confirm they are genuinely not in Task
3's copy list before skipping them.

- [ ] **Step 2: Run a mechanical scan for common secret shapes**

```bash
cd /Users/paul/.local/share/chezmoi
grep -rniE 'password|passwd|secret|api[_-]?key|token|BEGIN [A-Z ]*PRIVATE KEY|ghp_|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}' \
  --exclude-dir=.git --exclude-dir=.jj . || echo "NO MECHANICAL HITS"
```

Note: this is a first pass, not the audit. Hits are expected and mostly benign (`dot_bashrc` defines a `q` function and a password-generating `:Rnd` nvim command). Record each hit and its verdict.

- [ ] **Step 3: Read every file end to end**

Read all 39 in-scope files in full. Mechanical scanning does not catch a hardcoded internal hostname, a private tailnet IP, an employer-identifying path, or a personal API endpoint. Known items to adjudicate explicitly:

- `dot_config/private_karabiner/private_karabiner.json` — large generated file, read it fully
- `dot_claude/settings.json` — permissions and hook commands
- `dot_hammerspoon/init.lua` and the three Spoons
- `private_dot_npmrc` — verified as a single `prefix=` line, no auth token
- `dot_config/git/config` — verified: no credential helper with embedded secrets

- [ ] **Step 4: Record findings**

Write `docs/superpowers/plans/2026-08-27-secret-audit.md` listing every file, its verdict (`clean` / `needs redaction` / `must stay private`), and the reasoning for anything not `clean`.

- [ ] **Step 5: Decision gate**

If every file is `clean`, proceed to Task 3.

If **any** file is `needs redaction` or `must stay private`, **stop and escalate to Paul.** The spec's "one repo, public" decision assumed a clean audit; a single sensitive file reopens the repository-visibility choice and this plan must be revised before continuing.

- [ ] **Step 6: Commit the audit record**

```bash
cd /etc/nix-darwin
jj describe -m "Record dotfiles secret audit ahead of publishing to the public repo"
jj new
```

---

### Task 3: Land the dotfiles into the nix repo

Pure file movement. No behaviour change — nothing imports these yet.

**Files:**
- Create: `home/dotfiles/**` (37 files)
- Create: `~/.hammerspoon/private.lua` (outside the repo, deliberately unversioned)
- Modify: `home/dotfiles/hammerspoon/init.lua` (parameterize site-local values)
- Delete: `common/users/ghostty` (stale orphan, unreferenced)

**Interfaces:**
- Consumes: the audited tree from Task 2.
- Produces: `home/dotfiles/<name>` paths consumed by Tasks 4, 5 and 6. The exact name mapping below is the contract.

- [ ] **Step 1: Confirm the orphan ghostty config is unreferenced**

```bash
cd /etc/nix-darwin
grep -rn "common/users" --include="*.nix" . || echo "UNREFERENCED - safe to delete"
```

Expected: `UNREFERENCED - safe to delete`. The chezmoi copy has ~15 settings this one lacks (theme, split keybinds, titlebar style) and is authoritative.

- [ ] **Step 2: Copy the dotfiles with their new names**

```bash
set -eu
SRC=/Users/paul/.local/share/chezmoi
DST=/etc/nix-darwin/home/dotfiles
mkdir -p "$DST"/{claude/commands,config/{bat,fontconfig,git,jj,karabiner,nvim/lua/plugins},hammerspoon/Spoons,ghostty}

cp "$SRC/dot_bash_profile"                      "$DST/bash_profile"
cp "$SRC/dot_bashrc"                            "$DST/bashrc"
cp "$SRC/dot_inputrc"                           "$DST/inputrc"
cp "$SRC/dot_sqliterc"                          "$DST/sqliterc"
cp "$SRC/dot_gitattributes"                     "$DST/gitattributes"
cp "$SRC/dot_gitignore_global"                  "$DST/gitignore_global"
cp "$SRC/empty_dot_tmux.conf"                   "$DST/tmux.conf"
cp "$SRC/private_dot_npmrc"                     "$DST/npmrc"

cp "$SRC/dot_claude/CLAUDE.md"                  "$DST/claude/CLAUDE.md"
cp "$SRC/dot_claude/commands/.keep"             "$DST/claude/commands/.keep"

cp "$SRC/dot_config/bat/config"                 "$DST/config/bat/config"
cp "$SRC/dot_config/fontconfig/fonts.conf"      "$DST/config/fontconfig/fonts.conf"
cp "$SRC/dot_config/git/config"                 "$DST/config/git/config-body"
cp "$SRC/dot_config/git/ignore"                 "$DST/config/git/ignore"
cp "$SRC/dot_config/jj/config.toml.tmpl"        "$DST/config/jj/50-main.toml"
cp "$SRC/dot_config/nvim/init.lua"              "$DST/config/nvim/init.lua"
cp "$SRC/dot_config/nvim/lazy-lock.json"        "$DST/config/nvim/lazy-lock.json"
cp "$SRC"/dot_config/nvim/lua/plugins/*.lua     "$DST/config/nvim/lua/plugins/"
cp "$SRC/dot_config/private_karabiner/private_karabiner.json" "$DST/config/karabiner/karabiner.json"

cp "$SRC/dot_hammerspoon/init.lua"              "$DST/hammerspoon/init.lua"
cp -R "$SRC/dot_hammerspoon/Spoons/."           "$DST/hammerspoon/Spoons/"

cp "$SRC/private_Library/private_Application Support/com.mitchellh.ghostty/config" "$DST/ghostty/config"
```

- [ ] **Step 3: Strip the templated identity out of the jj fragment**

`config/jj/50-main.toml` still carries the chezmoi template. Delete the entire `[user]` block — Task 4 generates identity separately.

**Keep the leading `#:schema` pragma comment.** It gives editors schema
validation and is valid in a `conf.d` fragment. Only the `[user]` block goes,
so the file begins:

```toml
#:schema https://docs.jj-vcs.dev/latest/config-schema.json

[ui]
diff-editor = ":builtin"
```

- [ ] **Step 4: Strip identity and hooksPath out of the git body**

`config/git/config-body` must not set identity or `core.hooksPath` — Task 5 generates both. Remove the `[user]` section entirely, and remove only the `hooksPath` line from `[core]`, leaving the rest of `[core]` intact. Verify:

```bash
cd /etc/nix-darwin
grep -nE '^\[user\]|hooksPath' home/dotfiles/config/git/config-body || echo "STRIPPED"
```

Expected: `STRIPPED`.

- [ ] **Step 5: Pin the canonical ghostty config**

This is the authoritative content. Write `home/dotfiles/ghostty/config` with
exactly this, which also fixes the missing trailing newline the chezmoi copy
has:

```
font-family = IosevkaTerm Nerd Font
font-size = 15
macos-option-as-alt = true
window-step-resize = true
copy-on-select = true
shell-integration-features = sudo,ssh-env,ssh-terminfo
#font-feature = -calt
#font-feature = -liga
#font-feature = -dlig
#font-family = 0xProto
theme = tokyonight
command = /run/current-system/sw/bin/bash --login -i
mouse-hide-while-typing = true
keybind = global:ctrl+grave_accent=toggle_quick_terminal
keybind = shift+enter=text:\n
keybind = alt+h=goto_split:left
keybind = alt+j=goto_split:down
keybind = alt+k=goto_split:up
keybind = alt+l=goto_split:right
macos-titlebar-style = tabs
minimum-contrast = 1.1
window-inherit-working-directory = false
tab-inherit-working-directory = true
split-inherit-working-directory = true
```

The `command =` path resolves through `environment.systemPackages`, which
nix-darwin populates from `users.users.paul.shell = pkgs.bashInteractive`.
Task 5 leaves that setting in the system config, so the path stays valid after
user packages move to `~/.nix-profile`.

- [ ] **Step 6: Parameterize the Hammerspoon site-local values**

The WiFi watcher in `hammerspoon/init.lua` hardcodes the home WiFi SSID and the
Tailscale exit-node hostname. Both must leave the repo before it becomes public
— an SSID is geolocatable through public wardriving databases.

**Do not write either value into any file under `/etc/nix-darwin`, including
this plan.** Move them, do not copy them.

In `home/dotfiles/hammerspoon/init.lua`, replace the two assignment lines
(currently `homeSSID = "…"` and `exitNode = "…"`) so the values come from an
unversioned file, and make the callback inert when it is absent:

```lua
-- Site-local values live in ~/.hammerspoon/private.lua, which is deliberately
-- not version controlled. Without it the WiFi watcher stays inactive.
local ok, priv = pcall(require, "private")
if not ok then
	priv = {}
end

homeSSID = priv.homeSSID
exitNode = priv.exitNode
```

Add a guard as the first statement inside `ssidChangedCallback`:

```lua
	if not homeSSID or not exitNode then
		return
	end
```

Leave the `tailscale` binary path as-is — a path to the Tailscale binary is not
sensitive.

**Search the whole file, not just those two lines.** The SSID is also
interpolated into a notification string further down. Every literal occurrence
must become a reference to the variable:

```bash
grep -n 'homeSSID\|exitNode' home/dotfiles/hammerspoon/init.lua
```

Every hit must be a variable reference, never a quoted literal.

Now create the unversioned file on this machine, moving the two original values
out of the chezmoi source and into it:

```bash
cat > ~/.hammerspoon/private.lua <<'LUA'
return {
	homeSSID = "REPLACE_WITH_VALUE_FROM_CHEZMOI_SOURCE",
	exitNode = "REPLACE_WITH_VALUE_FROM_CHEZMOI_SOURCE",
}
LUA
```

Then edit that file to carry the real values, read from
`/Users/paul/.local/share/chezmoi/dot_hammerspoon/init.lua` lines 47 and 51.

Verify the values are gone from the repo copy and present in the private file:

```bash
cd /etc/nix-darwin
grep -nE '^(homeSSID|exitNode) = "' home/dotfiles/hammerspoon/init.lua \
  && echo "STILL HARDCODED - FAIL" || echo "PARAMETERIZED - PASS"
lua -e 'local p = dofile(os.getenv("HOME").."/.hammerspoon/private.lua"); assert(p.homeSSID and p.exitNode); print("private.lua OK")' \
  2>/dev/null || grep -c 'homeSSID' ~/.hammerspoon/private.lua
```

Expected: `PARAMETERIZED - PASS`, and the private file contains both keys.

This creates a per-machine manual step: `oberon` and `andon` each need their own
`~/.hammerspoon/private.lua`. Task 9 covers it for `oberon`; the `andon`
checklist must include it.

- [ ] **Step 7: Delete the stale ghostty orphan**

```bash
cd /etc/nix-darwin
rm -r common
```

- [ ] **Step 8: Verify the landed tree**

```bash
cd /etc/nix-darwin
echo -n "landed files: "; find home/dotfiles -type f | wc -l
jq empty home/dotfiles/config/karabiner/karabiner.json && echo "karabiner VALID"
jq empty home/dotfiles/config/nvim/lazy-lock.json && echo "lazy-lock VALID"
bash -n home/dotfiles/bashrc && echo "bashrc OK"
bash -n home/dotfiles/bash_profile && echo "bash_profile OK"
```

Expected: `landed files: 37`, and all four validations pass.

Then re-run the audit's mechanical scan against the landed tree, since this is
the content that actually becomes public:

```bash
cd /etc/nix-darwin
grep -rniE 'password|secret|api[_-]?key|token|BEGIN [A-Z ]*PRIVATE KEY|ghp_|AKIA[0-9A-Z]{16}' home/dotfiles/ \
  || echo "NO MECHANICAL HITS"
grep -rnE '^\s*(homeSSID|exitNode)\s*=\s*"' home/dotfiles/ \
  && echo "SITE-LOCAL VALUE LEAKED - FAIL" || echo "NO SITE-LOCAL VALUES - PASS"
```

Expected: the two known-benign hits from the audit only, and
`NO SITE-LOCAL VALUES - PASS`.

- [ ] **Step 9: Commit**

```bash
cd /etc/nix-darwin
jj describe -m "Land chezmoi dotfiles into home/dotfiles

Copies the reconciled dotfile set in with chezmoi's dot_/private_/empty_
prefixes stripped. Identity is removed from the git and jj bodies so Home
Manager can generate it per host. Deletes common/users/ghostty, an
unreferenced copy missing roughly fifteen settings the chezmoi one has."
jj new
```

---

### Task 4: Stand up standalone Home Manager with the live dotfile tier

Dotfiles only. Packages stay in the system config so this task is revertible without changing what is installed.

**Files:**
- Create: `lib/mkhome.nix`
- Create: `home/common.nix`, `home/darwin.nix`, `home/linux.nix`
- Create: `home/hosts/io.nix`, `home/hosts/oberon.nix`, `home/hosts/andon.nix`
- Modify: `flake.nix`
- Modify: `Makefile`
- Modify: `home/dotfiles/bashrc` (Step 7 — source `hm-session-vars.sh`)
- Modify: `home/dotfiles/config/git/config-body` (Step 13 — preserve `column.ui`)

These two dotfiles are in scope for this task. Everything else under
`home/dotfiles/` was finalised by Task 3 and must not be touched.

**Interfaces:**
- Consumes: `home/dotfiles/<name>` from Task 3.
- Produces:
  - `mkHome` — called as `mkHome { hostname; email; system ? "aarch64-darwin"; user ? "paul"; isVibium ? false; homeRepoRoot ? "/etc/nix-darwin"; deliveryMode ? "symlink"; }` returning a `homeManagerConfiguration`.
  - Flake outputs `homeConfigurations."paul@io"`, `"paul@oberon"`, `"paul@andon"`.
  - `extraSpecialArgs` available to every home module: `inputs`, `unstablePkgs`, `username`, `hostname`, `isVibium`, `email`, `homeRepoRoot`, `deliveryMode`.
  - `home/common.nix` exposes no options; it sets `home.file` entries only.

- [ ] **Step 1: Write the failing verification**

```bash
cd /etc/nix-darwin
nix eval .#homeConfigurations."paul@io".activationPackage --raw
```

Expected: FAIL — `error: attribute 'homeConfigurations' missing`.

- [ ] **Step 2: Create `lib/mkhome.nix`**

```nix
{
  nixpkgs,
  overlays,
  inputs,
}: {
  hostname,
  email,
  system ? "aarch64-darwin",
  user ? "paul",
  isVibium ? false,
  homeRepoRoot ? "/etc/nix-darwin",
  deliveryMode ? "symlink",
}: let
  lib = nixpkgs.lib;

  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  platform =
    if lib.hasSuffix "-darwin" system
    then "darwin"
    else "linux";

  hostModule = ../home/hosts/${hostname}.nix;
in
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs = {
      inherit
        inputs
        unstablePkgs
        hostname
        isVibium
        email
        homeRepoRoot
        deliveryMode
        ;
      username = user;
    };

    modules =
      [
        ../home/common.nix
        ../home/${platform}.nix
      ]
      ++ lib.optional (builtins.pathExists hostModule) hostModule;
  }
```

- [ ] **Step 3: Create `home/common.nix`**

The `dotfile` helper is the heart of the design: one source, two delivery modes.

```nix
{
  config,
  lib,
  username,
  email,
  homeRepoRoot,
  deliveryMode,
  ...
}: let
  # Deliver a dotfile either as a symlink into the live working repo, so
  # edits take effect without a switch, or as a copy in the Nix store for
  # hosts that have no checkout.
  dotfile = name:
    if deliveryMode == "symlink"
    then config.lib.file.mkOutOfStoreSymlink "${homeRepoRoot}/home/dotfiles/${name}"
    else ./dotfiles/${name};

  gitConfigBody =
    if deliveryMode == "symlink"
    then "${homeRepoRoot}/home/dotfiles/config/git/config-body"
    else "${./dotfiles/config/git/config-body}";
in {
  home = {
    inherit username;
    stateVersion = "26.05";

    sessionVariables = {
      EDITOR = "nvim";
      SVDIR = "$HOME/service";
      FONTCONFIG_FILE = "$HOME/.config/fontconfig/fonts.conf";
    };

    file = {
      ".bashrc".source = dotfile "bashrc";
      ".bash_profile".source = dotfile "bash_profile";
      ".inputrc".source = dotfile "inputrc";
      ".sqliterc".source = dotfile "sqliterc";
      ".gitattributes".source = dotfile "gitattributes";
      ".gitignore_global".source = dotfile "gitignore_global";
      ".tmux.conf".source = dotfile "tmux.conf";
      ".npmrc".source = dotfile "npmrc";

      ".claude/CLAUDE.md".source = dotfile "claude/CLAUDE.md";

      ".config/bat/config".source = dotfile "config/bat/config";
      ".config/fontconfig/fonts.conf".source = dotfile "config/fontconfig/fonts.conf";
      ".config/git/ignore".source = dotfile "config/git/ignore";

      # Identity is generated per host; the body is edited live. git merges
      # the two via [include].
      ".config/git/config".text = ''
        [user]
        	name = Paul Smith
        	email = ${email}

        [core]
        	hooksPath = ${config.home.homeDirectory}/.config/git/hooks

        [include]
        	path = ${gitConfigBody}
      '';

      # jj merges config.toml and every conf.d/*.toml in lexical order.
      ".config/jj/conf.d/00-identity.toml".text = ''
        [user]
        name = "Paul Smith"
        email = "${email}"
      '';
      ".config/jj/conf.d/50-main.toml".source = dotfile "config/jj/50-main.toml";
    };
  };

  # programs.bash would write ~/.bashrc, which is exactly the file delivered
  # above. Left disabled everywhere; bashrc sources hm-session-vars.sh itself.
  programs.home-manager.enable = true;

  xdg.enable = true;
}
```

- [ ] **Step 4: Create `home/darwin.nix`**

```nix
{
  config,
  homeRepoRoot,
  deliveryMode,
  ...
}: let
  dotfile = name:
    if deliveryMode == "symlink"
    then config.lib.file.mkOutOfStoreSymlink "${homeRepoRoot}/home/dotfiles/${name}"
    else ./dotfiles/${name};
in {
  home = {
    homeDirectory = "/Users/${config.home.username}";

    file = {
      # Symlinked as whole directories so lazy.nvim writes lazy-lock.json
      # straight back into the repo.
      ".config/nvim/init.lua".source = dotfile "config/nvim/init.lua";
      ".config/nvim/lazy-lock.json".source = dotfile "config/nvim/lazy-lock.json";
      ".config/nvim/lua".source = dotfile "config/nvim/lua";

      ".config/karabiner/karabiner.json".source = dotfile "config/karabiner/karabiner.json";

      ".hammerspoon/init.lua".source = dotfile "hammerspoon/init.lua";
      ".hammerspoon/Spoons".source = dotfile "hammerspoon/Spoons";

      "Library/Application Support/com.mitchellh.ghostty/config".source =
        dotfile "ghostty/config";
    };
  };
}
```

- [ ] **Step 5: Create `home/linux.nix`**

```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    homeDirectory = "/home/${config.home.username}";

    # Only init.lua is managed; lazy.nvim owns the plugin tree and needs it
    # writable, which a store path is not.
    file.".config/nvim/init.lua".source = ./dotfiles/config/nvim/init.lua;

    activation.removeLegacyNvimPluginSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for path in "$HOME/.config/nvim/lazy-lock.json" "$HOME/.config/nvim/lua"; do
        if [ -L "$path" ]; then
          target="$(${pkgs.coreutils}/bin/readlink "$path")"
          case "$target" in
            /nix/store/*) ${pkgs.coreutils}/bin/rm "$path" ;;
          esac
        fi
      done
    '';
  };

  fonts.fontconfig.enable = true;
}
```

- [ ] **Step 6: Create the three host modules**

`home/hosts/io.nix`:

```nix
{...}: {
}
```

`home/hosts/oberon.nix`:

```nix
{...}: {
}
```

`home/hosts/andon.nix`:

```nix
{...}: {
}
```

These are intentionally empty. Identity already flows through `email`; Task 6 adds `google-cloud-sdk` to `andon`.

- [ ] **Step 7: Make bashrc pick up `home.sessionVariables`**

`programs.bash.enable` is deliberately off, so nothing sources Home Manager's
generated session variables. Without this, `EDITOR`, `SVDIR` and
`FONTCONFIG_FILE` set in `home/common.nix` never reach the shell.

Add to `home/dotfiles/bashrc`, immediately after the
`[[ $- == *i* ]] || return` guard near the top:

```bash
# Home Manager session variables (programs.bash is intentionally disabled
# so this file can be delivered as a live symlink).
hm_session_vars="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
if [ -f "$hm_session_vars" ]; then
    builtin source "$hm_session_vars"
fi
unset hm_session_vars
```

Then remove the now-duplicated `export SVDIR=` and
`export FONTCONFIG_FILE=` lines further down the file, and the standalone
`export EDITOR=nvim` line near the bottom. Verify it still parses:

```bash
bash -n /etc/nix-darwin/home/dotfiles/bashrc && echo "bashrc OK"
```

Expected: `bashrc OK`.

- [ ] **Step 8: Wire `homeConfigurations` into `flake.nix`**

In the `let` block, after the existing `mkSystem` binding, add:

```nix
    mkHome = import ./lib/mkhome.nix {
      inherit nixpkgs overlays inputs;
    };
```

In the outputs attrset, after `nixosConfigurations.agent-vm`, add:

```nix
    homeConfigurations = {
      "paul@io" = mkHome {
        hostname = "io";
        email = "paulsmith@pobox.com";
      };

      "paul@oberon" = mkHome {
        hostname = "oberon";
        email = "paulsmith@pobox.com";
      };

      "paul@andon" = mkHome {
        hostname = "andon";
        email = "paul@vibium.com";
        isVibium = true;
      };
    };
```

- [ ] **Step 9: Add the `home` target to the Makefile**

After the `switch:` target, add:

```make
HOME_TARGET ?= $(shell id -un)@$(HOSTNAME)

home:
	home-manager switch --flake ".#$(HOME_TARGET)" -b hm-bak
```

Add `home` to the `.PHONY` line.

`-b hm-bak` is what makes the first activation survive chezmoi's real files. Leave it in permanently; it is a no-op once nothing is in the way.

- [ ] **Step 10: Format and check**

```bash
cd /etc/nix-darwin
nix fmt
nix flake check --no-build
```

Expected: PASS.

- [ ] **Step 11: Run the verification from Step 1 again**

```bash
cd /etc/nix-darwin
nix eval .#homeConfigurations."paul@io".activationPackage --raw
```

Expected: PASS — a `/nix/store/...` path.

- [ ] **Step 12: Build without activating and inspect the symlinks**

```bash
cd /etc/nix-darwin
nix build .#homeConfigurations."paul@io".activationPackage -o /tmp/hm-io
grep -c 'etc/nix-darwin/home/dotfiles' /tmp/hm-io/home-files/.bashrc 2>/dev/null \
  || readlink /tmp/hm-io/home-files/.bashrc
```

Expected: the `.bashrc` entry resolves to `/etc/nix-darwin/home/dotfiles/bashrc`, not a `/nix/store` path. If it points into the store, `deliveryMode` did not reach `common.nix`.

- [ ] **Step 13: Clear the two unmanaged configs that shadow the generated ones**

Home Manager manages neither of these, so it will never back them up — and both
are read *in addition to* the generated files, with the unmanaged copy winning.
A stale copy silently overrides the new per-host identity.

**jj** merges `config.toml` with everything in `conf.d/`:

```bash
mv ~/.config/jj/config.toml ~/.config/jj/config.toml.pre-hm
```

**git** reads `~/.gitconfig` *after* `~/.config/git/config`, so it wins on
duplicate keys. Leaving it in place means `user.email` keeps resolving to the
old value while jj uses the new one — the cause of a long-standing split
authorship in these repos.

```bash
mv ~/.gitconfig ~/.gitconfig.pre-hm
```

Before moving it, note what it uniquely provides. `core.excludesfile` is safe to
lose: git's default when unset is `$XDG_CONFIG_HOME/git/ignore`, which Home
Manager now manages and which is a strict superset of the old file. But
`column.ui = auto` would be genuinely lost, so add it to
`home/dotfiles/config/git/config-body`:

```
[column]
	ui = auto
```

- [ ] **Step 14: Dry-run the activation, and snapshot the two directories**

Twenty real files in `$HOME` will be moved aside as `*.hm-bak`. **Two of them
are directories** — `.config/nvim/lua` and `.hammerspoon/Spoons`.
`backupFileExtension` is well-proven for files; directories are the untested
case, and a bad move takes the whole nvim plugin tree with it.

Snapshot them first, so a bad move is recoverable no matter what:

```bash
cp -R ~/.config/nvim/lua /tmp/nvim-lua-backup
cp -R ~/.hammerspoon/Spoons /tmp/hammerspoon-spoons-backup
ls /tmp/nvim-lua-backup /tmp/hammerspoon-spoons-backup >/dev/null && echo "snapshots taken"
```

Then dry-run:

```bash
cd /etc/nix-darwin
nix run home-manager -- switch --flake ".#$(id -un)@$(hostname)" -b hm-bak --dry-run 2>&1 | tail -40
```

Expected: it reports moving existing paths aside and creating symlinks, and
exits 0. **If it errors on either directory, STOP and report** — do not proceed
to Step 15.

- [ ] **Step 15: Activate on io**

The **first** activation cannot use `make home`: the `home-manager` binary is
not on `PATH` until an activation installs it into the profile. Bootstrap with
`nix run` — the same invocation Step 14 already validated, minus `--dry-run`:

```bash
cd /etc/nix-darwin
nix run home-manager -- switch --flake ".#$(id -un)@$(hostname)" -b hm-bak
```

Every subsequent activation uses `make home`. Verify that now:

```bash
hash -r && command -v home-manager && make home
```

Expected: activation succeeds. Files chezmoi had written are moved aside as `*.hm-bak`.

- [ ] **Step 16: Verify the live tier is genuinely live**

```bash
readlink -f ~/.bashrc
```

Expected: `/private/etc/nix-darwin/home/dotfiles/bashrc`.

Use `readlink -f`, not `readlink`. `mkOutOfStoreSymlink` composes with home-
manager's file-linking to produce a multi-hop chain
(`~/.bashrc` → home-manager-files → `hm_bashrc` → repo). That is inherent, not a
defect; what matters is that the chain terminates inside the repo rather than at
a store copy.

```bash
jj config get user.email
git config --get user.email
git config --get diff.algorithm
```

Expected: `paulsmith@pobox.com`, `paulsmith@pobox.com`, `histogram` (proving the `[include]` body is being read).

```bash
echo "# live-edit probe" >> /etc/nix-darwin/home/dotfiles/bashrc
tail -1 ~/.bashrc
```

Expected: `# live-edit probe` — with no switch. Then remove the probe line.

- [ ] **Step 17: Commit**

```bash
cd /etc/nix-darwin
nix fmt
jj describe -m "Deliver dotfiles through standalone Home Manager

Adds lib/mkhome.nix and homeConfigurations for the three Darwin hosts.
Dotfiles resolve as out-of-store symlinks into the working repo so edits
apply without a switch, while the VMs get store copies from the same
sources. Identity for git and jj is generated per host and layered over
the live bodies via [include] and jj's conf.d."
jj new
```

---

### Task 5: Move user packages to `home.packages`

Kept separate from Task 4 so a package regression is diagnosable on its own.

**Files:**
- Create: `home/packages/workstation.nix`, `home/packages/vm.nix`
- Delete: `modules/packages/workstation.nix`, `modules/packages/vm.nix`, `users/paulsmith/home.nix`
- Modify: `lib/mksystem.nix`, `lib/mkhome.nix`, `users/paul/darwin.nix`, `hosts/andon/configuration.nix`, `home/hosts/andon.nix`, `home/darwin.nix`, `home/linux.nix`

**Interfaces:**
- Consumes: `mkHome` and the `extraSpecialArgs` contract from Task 4.
- Produces: `home/packages/workstation.nix` and `home/packages/vm.nix`, each a plain home module setting `home.packages`. Imported by `home/darwin.nix` and `home/linux.nix` respectively.

- [ ] **Step 1: Write the failing verification**

```bash
cd /etc/nix-darwin
nix build .#homeConfigurations."paul@io".activationPackage -o /tmp/hm-pkgs
ls /tmp/hm-pkgs/home-path/bin/bat
```

Expected: FAIL — `No such file or directory`. Packages are still in the system profile.

Use `bat` as the canary, **not `rg`**. `ripgrep` lives in `modules/packages/core.nix`
as `environment.systemPackages`, which Step 7 keeps system-level by design — so it
could never appear in `home-path` no matter what this task does.

- [ ] **Step 2: Create `home/packages/workstation.nix`**

Move the list from `modules/packages/workstation.nix` verbatim, changing only the option and the wrapper. `chezmoi` stays for now — Task 8 removes it.

```nix
{
  pkgs,
  unstablePkgs,
  ...
}: let
  agentVmRun = pkgs.writeShellScriptBin "agent-vm-run" ''
    exec ${pkgs.gnumake}/bin/make --no-print-directory -C /private/etc/nix-darwin agent-vm-run "$@"
  '';
in {
  home.packages =
    (with pkgs; [
      age
      autossh
      bash-completion
      bat
      btop
      cachix
      chafa # terminal graphics protocol - image viewer (Ghostty)
      chezmoi
      clang-tools # clang-format, clangd
      cmake
      coreutils-prefixed
      difftastic
      direnv
      dtach
      e2fsprogs
      entr
      fastfetch
      ffmpeg
      fx
      fzf
      gh
      gifsicle
      gifski
      go-bin.latestStable # this is coming from go-overlay
      golangci-lint
      graphviz
      guile
      helix
      herdr
      htop
      hugo
      hyperfine
      iftop
      imagemagick
      jujutsu # this is coming from the jj flake overlay
      lua-language-server
      magic-wormhole
      mas
      mitmproxy
      mosh
      ninja
      nix-direnv
      nodejs_24
      optipng
      pandoc
      postgresql
      pstree
      pv
      python3
      rclone
      readline
      restic
      rlwrap
      rrdtool
      rustup
      shellcheck
      sqlite
      stylua
      swig
      tree
      tree-sitter
      typst
      xz
      yt-dlp
      zstd
    ])
    ++ [
      agentVmRun
      unstablePkgs.neovim
      unstablePkgs.pnpm
      unstablePkgs.uv
    ];
}
```

`coreutils-prefixed`, `e2fsprogs` and `mas` are folded in here from
`users/paul/darwin.nix`. `tmux` is deliberately **absent** — it is declared in
`modules/packages/core.nix` and stays a system package, so it is declared once
rather than twice.

Arithmetic to check against: 67 original − 1 (`tmux`) + 3 stragglers = **69**.

- [ ] **Step 3: Create `home/packages/vm.nix`**

```nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    bashInteractive
    btop
    fastfetch
    htop
    iftop
    pstree
    pv
    python3
    readline
    rlwrap
    tmux
    tree
    xz
    zstd
  ];
}
```

- [ ] **Step 4: Import the package sets from the platform modules**

At the top of `home/darwin.nix`, add:

```nix
  imports = [./packages/workstation.nix];
```

At the top of `home/linux.nix`, add:

```nix
  imports = [./packages/vm.nix];
```

- [ ] **Step 5: Add `google-cloud-sdk` to andon's home module**

`home/hosts/andon.nix`:

```nix
{pkgs, ...}: {
  home.packages = [pkgs.google-cloud-sdk];
}
```

- [ ] **Step 6: Strip the moved packages out of the system configuration**

In `users/paul/darwin.nix`, delete the entire `users.users.paul.packages` attribute (the `coreutils-prefixed` / `e2fsprogs` / `mas` list). Leave the second `users.users.paul` block — home, shell, description, authorizedKeys — untouched.

In `hosts/andon/configuration.nix`, delete the `environment.systemPackages` line.

Delete the two now-unused files:

```bash
cd /etc/nix-darwin
rm modules/packages/workstation.nix modules/packages/vm.nix users/paulsmith/home.nix
```

- [ ] **Step 7: Drop the package profiles from `mksystem.nix`**

The `packageProfiles` indirection existed only to pick between the two lists
that just moved to `home/packages/`. Replace `lib/mksystem.nix` in full — Tasks
6 and 7 append to the Darwin-only `lib.optionals` list, so it needs to be
unambiguous:

```nix
{
  nixpkgs,
  overlays,
  inputs,
  configurationRevision,
}: name: {
  system ? "aarch64-darwin",
  user,
  isVibium ? false,
  nextdnsProfile ? null,
}: let
  lib = nixpkgs.lib;

  isDarwin = system: lib.hasSuffix "-darwin" system;
  isLinux = !isDarwin system;
  platform =
    if isDarwin system
    then "darwin"
    else "nixos";

  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  platformConfig = ../modules/${platform}/common.nix;
  hostConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = ../users/${user}/${platform}.nix;

  systemFn =
    if isLinux
    then lib.nixosSystem
    else inputs.darwin.lib.darwinSystem;
in
  systemFn {
    inherit system;

    specialArgs = {
      inherit
        inputs
        configurationRevision
        isVibium
        nextdnsProfile
        unstablePkgs
        ;
      hostname = name;
      username = user;
    };

    modules =
      lib.optionals (isDarwin system) [
        inputs.nix-rosetta-builder.darwinModules.default
      ]
      ++ [
        {
          nixpkgs = {
            overlays = overlays;
            config.allowUnfree = true;
          };
        }
        ../modules/packages/core.nix
        ../users/ssh-pubkeys.nix
        platformConfig
        hostConfig
        userOSConfig
      ];
  }
```

In `flake.nix`, remove the now-unused `packageProfile = "vm";` line from
`mkPaulLinuxVm`.

- [ ] **Step 8: Format and check**

```bash
cd /etc/nix-darwin
nix fmt
nix flake check --no-build
darwin-rebuild build --flake .#io
```

Expected: all PASS.

- [ ] **Step 9: Run the verification from Step 1 again**

```bash
cd /etc/nix-darwin
nix build .#homeConfigurations."paul@io".activationPackage -o /tmp/hm-pkgs
ls /tmp/hm-pkgs/home-path/bin/bat /tmp/hm-pkgs/home-path/bin/jj /tmp/hm-pkgs/home-path/bin/uv
```

Expected: PASS — all three resolve. `jj` proves the overlay reached `mkHome`; `uv` proves `unstablePkgs` did.

- [ ] **Step 10: Activate and confirm the profile moved**

```bash
cd /etc/nix-darwin
make home
sudo darwin-rebuild switch --flake .#io
hash -r
command -v bat jj uv
```

Expected: `bat` and `jj` resolve under `/Users/paul/.nix-profile/bin`.

`uv` may resolve to `~/.local/bin/uv` instead — a pre-existing pipx install that
shadows the Nix one on PATH. That is not a defect in this task; confirm
`~/.nix-profile/bin/uv` exists and points at the store path just built.

- [ ] **Step 11: Commit**

```bash
cd /etc/nix-darwin
nix fmt
jj describe -m "Move user packages from the system config to home.packages

Relocates the workstation and VM package sets under home/packages and
folds in the three stragglers from users/paul/darwin.nix plus andon's
google-cloud-sdk. Package changes now activate through home-manager
switch without sudo. modules/packages/core.nix stays as
environment.systemPackages so root keeps git, curl and vim."
jj new
```

---

### Task 6: Consolidate Homebrew into one non-destructive manifest

**Files:**
- Create: `modules/darwin/homebrew.nix`
- Modify: `users/paul/darwin.nix`, `lib/mksystem.nix`, `hosts/io/configuration.nix`

**Interfaces:**
- Consumes: `isVibium` from `specialArgs` (already provided by `mksystem.nix`).
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Write the failing verification**

```bash
cd /etc/nix-darwin
nix eval .#darwinConfigurations.io.config.homebrew.onActivation.cleanup --raw
```

Expected: `uninstall` — the destructive setting this task removes.

- [ ] **Step 2: Create `modules/darwin/homebrew.nix`**

```nix
{
  lib,
  isVibium,
  ...
}: {
  homebrew = {
    enable = true;

    # Never uninstall. Nix guarantees this list is present; anything
    # installed by hand survives untouched.
    onActivation.cleanup = "none";

    taps = [
      "1password/tap"
      "ngrok/ngrok"
    ];

    brews = [
      "cowsay"
      "opam"
      "qemu"
    ];

    casks =
      [
        "1password"
        "1password-cli"
        "basictex"
        "claude"
        "cleanshot"
        "codex-app"
        "dangerzone"
        "google-chrome"
        "hammerspoon"
        "handy"
        "istat-menus"
        "karabiner-elements"
        "ngrok"
        "obsidian"
        "qlmarkdown"
        "secretive"
        "slack"
        "utm"
      ]
      ++ lib.optionals (!isVibium) [
        "audacity"
        "avifquicklook"
        "discord"
        "elmedia-player"
        "gimp"
        "iina"
        "inkscape"
        "kicad"
        "libreoffice"
        "musicbrainz-picard"
        "rar"
        "selfcontrol"
        "slideshower"
      ];

    masApps =
      {
        "Kagi Search" = 1622835804;
        "Keynote" = 409183694;
        "Microsoft Excel" = 462058435;
        "Numbers" = 409203825;
        "Pages" = 409201541;
        "Swift Playground" = 1496833156;
        "TestFlight" = 899247664;
        "Tomito" = 1526042938;
        "Xcode" = 497799835;
      }
      // lib.optionalAttrs (!isVibium) {
        "Bike" = 1588292384;
        "Blackmagic Disk Speed Test" = 425264550;
        "Brother P-touch Editor" = 1453365242;
        "File Viewer" = 495987613;
        "Free Ruler" = 1483172210;
        "GarageBand" = 682658836;
        "Hand Mirror" = 1502839586;
        "Hyperspace" = 6739505345;
        "iMovie" = 408981434;
        "Ivory" = 6444602274;
        "Mimeo Photos" = 1282504627;
        "Nitro" = 1591292532;
        "OneTab" = 1540160809;
        "Prime Video" = 545519333;
        "Ruler" = 1563264206;
        "Steam Link" = 1246969117;
        "StopTheMadness" = 1376402589;
        "Tot" = 1491071483;
        "WhatsApp" = 310633997;
        "WorldWideWeb" = 1621370168;
      };
  };
}
```

`ghostty` is deliberately absent — the nightly build is installed by hand and declaring the cask would overwrite it. `docker`, `docker-buildx` and `docker-compose` are dropped. `mas`, `bash-completion` and `runit` come from Nix instead.

- [ ] **Step 3: Add `Notchmeister` to io only**

In `hosts/io/configuration.nix`, add at the top level of the attrset:

```nix
  homebrew.masApps."Notchmeister" = 1599169747;
```

- [ ] **Step 4: Remove the old block and import the new module**

Delete the entire `homebrew = { ... };` attribute from `users/paul/darwin.nix`.

In `lib/mksystem.nix`, add `../modules/darwin/homebrew.nix` to the Darwin-only `lib.optionals (isDarwin system)` list, next to `inputs.nix-rosetta-builder.darwinModules.default`.

- [ ] **Step 5: Format and check**

```bash
cd /etc/nix-darwin
nix fmt
nix flake check --no-build
darwin-rebuild build --flake .#io
darwin-rebuild build --flake .#andon
```

Expected: all PASS. Building `andon` as well proves the `isVibium` split evaluates.

- [ ] **Step 6: Verify the split and the non-destructive setting**

```bash
cd /etc/nix-darwin
nix eval .#darwinConfigurations.io.config.homebrew.onActivation.cleanup --raw
nix eval .#darwinConfigurations.io.config.homebrew.casks --json | jq 'length'
nix eval .#darwinConfigurations.andon.config.homebrew.casks --json | jq 'length'
nix eval .#darwinConfigurations.io.config.homebrew.casks --json | jq 'index("ghostty")'
```

Expected: `none`; io has 31 casks; andon has 18; `null` for ghostty on io.

- [ ] **Step 7: Switch and confirm nothing was uninstalled**

```bash
brew list --cask > /tmp/casks-before.txt
cd /etc/nix-darwin && sudo darwin-rebuild switch --flake .#io
brew list --cask > /tmp/casks-after.txt
comm -23 /tmp/casks-before.txt /tmp/casks-after.txt
```

Expected: empty output — nothing was removed. New casks may appear; none may disappear.

- [ ] **Step 8: Commit**

```bash
cd /etc/nix-darwin
nix fmt
jj describe -m "Consolidate Homebrew into one non-destructive manifest

Merges the chezmoi brew bundle into the Nix homebrew block and moves it
out of the user config into modules/darwin/homebrew.nix. cleanup is now
\"none\", so a switch never uninstalls: the two competing manifests were
what wiped hand-installed packages. Personal apps are gated on isVibium
so the work machine does not get them. ghostty stays undeclared because
the nightly build is installed by hand."
jj new
```

---

### Task 7: Supervise runit with launchd instead of Homebrew

**Files:**
- Create: `modules/darwin/runit.nix`
- Modify: `lib/mksystem.nix`

**Interfaces:**
- Consumes: `pkgs.runit` from `modules/packages/core.nix`; `username` from `specialArgs`.
- Produces: a launchd agent labelled `org.nixos.runsvdir`.

- [ ] **Step 1: Write the failing verification**

```bash
cd /etc/nix-darwin
nix eval .#darwinConfigurations.io.config.launchd.user.agents.runsvdir.serviceConfig.Label --raw
```

Expected: FAIL — `attribute 'runsvdir' missing`.

- [ ] **Step 2: Create `modules/darwin/runit.nix`**

```nix
{
  pkgs,
  username,
  ...
}: {
  launchd.user.agents.runsvdir = {
    serviceConfig = {
      Label = "org.nixos.runsvdir";
      ProgramArguments = [
        "${pkgs.runit}/bin/runsvdir"
        "/Users/${username}/service"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/${username}/Library/Logs/runsvdir.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/runsvdir.log";
    };
  };
}
```

`SVDIR` is already exported as `$HOME/service` by `home/common.nix`, so `sv` finds the same directory the agent supervises.

- [ ] **Step 3: Import it for Darwin hosts**

In `lib/mksystem.nix`, add `../modules/darwin/runit.nix` to the same Darwin-only `lib.optionals` list used in Task 6.

- [ ] **Step 4: Ensure the service directory exists**

```bash
mkdir -p ~/service ~/Library/Logs
```

- [ ] **Step 5: Format, check, build**

```bash
cd /etc/nix-darwin
nix fmt
nix flake check --no-build
darwin-rebuild build --flake .#io
```

Expected: all PASS.

- [ ] **Step 6: Run the verification from Step 1 again**

```bash
cd /etc/nix-darwin
nix eval .#darwinConfigurations.io.config.launchd.user.agents.runsvdir.serviceConfig.Label --raw
```

Expected: `org.nixos.runsvdir`.

- [ ] **Step 7: Switch and confirm the supervisor is running**

```bash
cd /etc/nix-darwin && sudo darwin-rebuild switch --flake .#io
launchctl list | grep runsvdir
pgrep -fl runsvdir
```

Expected: the agent is listed and the process is running.

- [ ] **Step 8: Commit**

```bash
cd /etc/nix-darwin
nix fmt
jj describe -m "Supervise runit with launchd instead of Homebrew

Replaces the brew runit formula and its restart_service directive with a
launchd user agent running runsvdir against \$HOME/service, matching how
the NixOS side already supervises services."
jj new
```

---

### Task 8: Retire chezmoi and the dotfiles flake input

**Files:**
- Modify: `home/packages/workstation.nix`, `flake.nix`, `hosts/agent-vm/configuration.nix`
- Delete: `users/paul/agent-home.nix`
- Delete: `/Users/paul/.local/share/chezmoi/run_onchange_before_install-packages-darwin.sh.tmpl`

**Interfaces:**
- Consumes: `mkHome` from Task 4, `home/packages/vm.nix` from Task 5.
- Produces: `agent-vm` builds its home config from `home/` in store mode, with no `inputs.dotfiles`.

- [ ] **Step 1: Write the failing verification**

```bash
cd /etc/nix-darwin
grep -c 'dotfiles' flake.nix
```

Expected: non-zero — `inputs.dotfiles` is still declared.

- [ ] **Step 2: Point agent-vm's home config at the shared modules**

In `hosts/agent-vm/configuration.nix`, replace the `home-manager` block's user module and `extraSpecialArgs` so it imports `../../home/common.nix` and `../../home/linux.nix` instead of `../../users/paul/agent-home.nix`, and passes the same `extraSpecialArgs` contract Task 4 established:

```nix
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      unstablePkgs = import inputs.nixpkgs-unstable {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };
      username = "paul";
      hostname = "agent-vm";
      isVibium = false;
      email = "paulsmith@pobox.com";
      homeRepoRoot = "/etc/nix-darwin";
      deliveryMode = "store";
    };
    users.paul.imports = [
      ../../home/common.nix
      ../../home/linux.nix
    ];
  };
```

`deliveryMode = "store"` is what makes the VM hermetic — no checkout required.

- [ ] **Step 3: Delete the superseded files and inputs**

```bash
cd /etc/nix-darwin
rm users/paul/agent-home.nix
rm /Users/paul/.local/share/chezmoi/run_onchange_before_install-packages-darwin.sh.tmpl
```

In `flake.nix`, delete the entire `dotfiles = { ... };` input block.

In `home/packages/workstation.nix`, delete the `chezmoi` line.

- [ ] **Step 4: Update the lock file**

```bash
cd /etc/nix-darwin
nix flake lock
grep -c '"dotfiles"' flake.lock || echo "INPUT GONE"
```

Expected: `INPUT GONE`.

- [ ] **Step 5: Format, check, build both platforms**

```bash
cd /etc/nix-darwin
nix fmt
nix flake check --no-build
darwin-rebuild build --flake .#io
```

Expected: both PASS.

**The `agent-vm` build is an authorized skip.** Paul has explicitly decided not
to build it during this migration: `io` has no local `aarch64-linux` builder and
`oberon`'s rosetta-builder is refusing connections on port 31122.

Do **not** attempt the build, do not try to reach the builder, and do not treat
its absence as a blocker. Evaluate instead — this proves the configuration is
still well-formed after `inputs.dotfiles` is removed:

```bash
nix eval .#nixosConfigurations.agent-vm.config.system.build.toplevel.drvPath --raw
```

**Report explicitly that the agent-vm closure was never built**, so the risk is
visible: evaluation catches attribute and type errors, but not build-time
failures. The VM stays unproven until Paul builds it from `oberon`, or from `io`
once that builder is restored.

- [ ] **Step 6: Confirm the VM gets store-mode dotfiles**

```bash
cd /etc/nix-darwin
nix eval .#nixosConfigurations.agent-vm.config.home-manager.users.paul.home.file.".bashrc".source --raw
```

Expected: a `/nix/store/...` path, **not** `/etc/nix-darwin/...`. A repo path here means `deliveryMode` did not reach the module.

- [ ] **Step 7: Commit**

```bash
cd /etc/nix-darwin
nix fmt
jj describe -m "Retire chezmoi and the dotfiles flake input

agent-vm now builds its home configuration from the in-repo home/
modules in store delivery mode, so the stale dotfiles input, its lock
pin and the replaceStrings workarounds in agent-home.nix all go away.
Removes the chezmoi package and its brew bundle script."
jj new
```

- [ ] **Step 8: Freeze the old dotfiles repository**

Do **not** delete `ssh://bunny/media/nas/repo/dotfiles.git` or `/Users/paul/.local/share/chezmoi`. They are the rollback path. Push the reconciliation from Task 1 so the archive is complete:

The chezmoi repo's remotes are `bunny` (its original) and `github` (added in
Task 1 Step 3). There is no `origin` there.

```bash
cd /Users/paul/.local/share/chezmoi
jj git push --remote bunny --bookmark main
jj git push --remote github --bookmark main
```

Both remotes have commits the other lacks, so these pushes move each bookmark
forward past a divergence — expect to need `--allow-backwards` or a forced
push on whichever remote rejects the update. GitHub and bunny are both
archives at this point; either is acceptable as the surviving copy.

---

### Task 9: Roll out to oberon and andon

**Files:** none — this task verifies and activates existing configuration on two more machines.

**Interfaces:**
- Consumes: everything from Tasks 4–8.
- Produces: three machines on the unified configuration.

- [ ] **Step 1: Verify the repo path assumption on both machines**

On `oberon` and then `andon`:

```bash
test -d /etc/nix-darwin && echo "PATH OK" || echo "PATH DIFFERS - homeRepoRoot must become per-host"
```

Expected: `PATH OK`. If either differs, stop: add a `homeRepoRoot` argument to that host's `mkHome` call in `flake.nix` before continuing.

- [ ] **Step 2: Capture pre-existing chezmoi drift on each machine**

```bash
chezmoi status
chezmoi diff > ~/chezmoi-drift-$(hostname).patch
```

Any drift here is local work that never reached either remote. Review it and fold anything worth keeping into `home/dotfiles/` on a branch before activating, or it will be moved aside as `*.hm-bak` and forgotten.

- [ ] **Step 3: Pull the unified configuration**

```bash
cd /etc/nix-darwin
jj git fetch
jj new main
```

- [ ] **Step 4: Clear both shadowing configs**

Same reasoning as Task 4 Step 13 — these exist per machine, so `oberon` and
`andon` each need it:

```bash
mv ~/.config/jj/config.toml ~/.config/jj/config.toml.pre-hm
mv ~/.gitconfig ~/.gitconfig.pre-hm
```

Then confirm both tools agree:

```bash
git config --get user.email
jj config get user.email
```

- [ ] **Step 5: Recreate the Hammerspoon private file**

`~/.hammerspoon/private.lua` is deliberately not in the repo, so it does not
arrive with the checkout. Without it the WiFi watcher stays inert — no error,
just no exit-node switching. Copy the same two keys used on `io`:

```bash
cat > ~/.hammerspoon/private.lua <<'LUA'
return {
	homeSSID = "REPLACE",
	exitNode = "REPLACE",
}
LUA
```

Fill in the real values by hand. Do not transfer this file through the repo.

- [ ] **Step 6: Activate home, then system**

```bash
cd /etc/nix-darwin
make home
sudo darwin-rebuild switch --flake ".#$(hostname)"
```

- [ ] **Step 7: Verify identity, liveness and packages**

```bash
readlink ~/.bashrc
git config --get user.email
jj config get user.email
command -v bat jj uv
brew list --cask | head
```

Expected on `oberon`: `paulsmith@pobox.com`. Expected on `andon`: `paul@vibium.com`, and a cask list without the personal apps.

- [ ] **Step 8: Confirm nothing was uninstalled on either machine**

```bash
brew list --cask > /tmp/casks-after.txt
```

Compare against what was installed before the switch. Expected: no removals.

---

### Task 10: Add bunny as a backup remote

**Files:** none — remote configuration only.

**Interfaces:**
- Consumes: the completed migration.
- Produces: a second remote mirroring GitHub.

- [ ] **Step 1: Create the bare repository on bunny**

```bash
ssh bunny 'git init --bare /media/nas/repo/nixos-config.git'
```

- [ ] **Step 2: Add the remote**

```bash
cd /etc/nix-darwin
jj git remote add bunny ssh://bunny/media/nas/repo/nixos-config.git
jj git remote list
```

Expected: both `origin` and `bunny` listed.

- [ ] **Step 3: Push to both remotes**

```bash
cd /etc/nix-darwin
jj git push --remote origin --bookmark main
jj git push --remote bunny --bookmark main --allow-new
```

- [ ] **Step 4: Verify the mirror matches**

```bash
git ls-remote git@github.com:paulsmith/nixos-config.git main
git ls-remote ssh://bunny/media/nas/repo/nixos-config.git main
```

Expected: identical revisions. GitHub stays authoritative; when bunny diverges, force-push over it.

- [ ] **Step 5: Document activation, bootstrap and remotes in the README**

The README still describes a single `darwin-rebuild switch` and a `git clone`
bootstrap, both now wrong. Replace the "Setup" and "Building and Applying"
sections with:

````markdown
## Building and Applying

Two activation paths, deliberately separate:

```bash
make        # system: macOS defaults, Homebrew, nextdns, build machines (sudo)
make home   # user: packages and dotfiles (no sudo)
```

Dotfiles under `home/dotfiles/` are symlinked into `$HOME` from this working
tree, so editing one takes effect immediately — no switch needed. Run
`make home` only when adding or removing a file, or changing packages.

Apply to a specific host:

```bash
HOSTNAME=io make
HOME_TARGET=paul@io make home
```

## Bootstrapping a new machine

Order matters — the repo must exist at `/etc/nix-darwin` before Home Manager
activates, or the dotfile symlinks dangle:

```bash
git clone git@github.com:paulsmith/nixos-config.git /etc/nix-darwin
cd /etc/nix-darwin
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ".#$(hostname)"
nix run home-manager -- switch --flake ".#$(id -un)@$(hostname)" -b hm-bak
```

## Remotes

`origin` (GitHub) is authoritative. `bunny` is a locally-reachable mirror on the
NAS and may be force-pushed when it diverges:

```bash
jj git push --remote origin --bookmark main
jj git push --remote bunny --bookmark main
```
````

Also update the "Active flake outputs" list at the top to include `andon` and
the three `homeConfigurations`, and drop the stale claim that `andon` is the
host enabling `nix-rosetta-builder.onDemand` — `oberon` does too.

- [ ] **Step 6: Commit**

```bash
cd /etc/nix-darwin
jj describe -m "Document the bunny mirror and the two activation commands"
jj new
jj git push --remote origin --bookmark main
jj git push --remote bunny --bookmark main
```

---

## Deferred follow-ups

Recorded here so they are not lost; both are explicitly out of scope for this plan.

- **`make update` triggers a 14-minute rebuild.** `jj.url` tracks jj's main branch and `herdr` builds from source, with no `substituters` configured, so every input bump rebuilds a Rust toolchain. Fix by pinning `jj` to a release tag, switching to `pkgs.jujutsu`, or adding a binary cache.
- **`core.hooksPath` points at `~/.config/git/hooks`, which does not exist**, silently disabling git hooks on every machine. Task 4 preserves the existing behaviour rather than changing it. Decide whether to populate the directory or drop the setting.
