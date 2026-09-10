# The `/etc/nix-darwin` Manual

A guide to this machine configuration repository, written for someone who has
never used Nix.

---

## 1. What this repo is

Every Mac and VM here is configured from this one repository. Installed
packages, shell config, editor config, macOS settings, Homebrew apps — all of
it is declared in files you can read, and applied by running a command.

The idea that makes Nix different from a pile of shell scripts:

> You describe the state you want. Nix works out how to get there.

You never run `install this` or `set that`. You edit a file that says what
should be true, then apply it. If you delete the line, the thing goes away. If
two machines read the same files, they end up the same.

The practical payoff is that a broken change is *undoable*. Every apply creates
a numbered generation, and the previous one is still on disk.

---

## 2. The five things you need to know about Nix

You can be productive here without understanding Nix deeply. You do need these.

**The store.** Everything Nix installs lives in `/nix/store` under a path like
`/nix/store/vaxpw6gg…-bashrc`. That hash covers every input that produced it.
Change an input, get a different path. Store paths are read-only, always.

**Profiles are just symlink farms.** `~/.nix-profile/bin/bat` is a symlink into
the store. "Installing" means building a new profile and repointing a symlink,
which is why it's atomic and instant.

**Generations.** Each apply creates a new generation and keeps the old one.
Rollback is repointing a symlink, not reinstalling.

**Flakes.** `flake.nix` is the entry point; `flake.lock` pins the exact version
of every input. The lock file is why a build is reproducible — and why you must
commit it.

**Derivations.** A build recipe. `nix eval` checks that the recipe is
well-formed; only `nix build` actually runs it. This distinction matters: an
evaluation passing does **not** mean the thing builds.

---

## 3. The machines

![Hosts](diagrams/hosts.svg)

| Host | What it is | Notes |
| --- | --- | --- |
| `io` | Paul's laptop | Primary machine |
| `oberon` | Mac Studio | Also hosts the Linux builder for the VMs |
| `andon` | Work laptop | `isVibium = true` — gets a smaller app list |
| `nixos-vm`, `agent-vm` | Linux VMs | Built via `oberon`, not natively |

`andon` is the reason for the `isVibium` flag you'll see in the Nix files. Work
machines don't get GarageBand and Steam Link. That's the only per-host
divergence of any size.

---

## 4. How the repo is laid out

![Architecture](diagrams/architecture.svg)

```
flake.nix              entry point; declares hosts and inputs
flake.lock             pinned input versions — always commit it
lib/
  mksystem.nix         builds a darwinConfiguration (system tier)
  mkhome.nix           builds a homeConfiguration (user tier)
hosts/<name>/          per-machine system settings
modules/
  darwin/              macOS system: homebrew.nix, runit.nix, common.nix
  packages/core.nix    system packages (root needs these)
home/
  common.nix           user config shared by every host
  darwin.nix           macOS-only user config
  linux.nix            VM-only user config
  hosts/<name>.nix     per-machine user config
  packages/            user packages
  dotfiles/            37 plain files: bashrc, nvim, git, jj, ghostty…
overlays/              custom package definitions (e.g. d2)
```

The split that matters is **`modules/` is the system tier, `home/` is the user
tier.** Everything else follows from that.

---

## 5. The two-tier dotfile system

This is the part of the setup that's genuinely unusual. Read it twice.

Dotfiles live once, in `home/dotfiles/`. They are delivered two different ways
depending on the machine.

![Two tiers](diagrams/tiers.svg)

**On a Mac**, `~/.bashrc` is a *symlink* pointing back into the repo:

```
~/.bashrc -> /etc/nix-darwin/home/dotfiles/bashrc
```

Edit that file and the change is live in the next shell. No rebuild, no
command, nothing. This is deliberate — it's the whole reason the setup is
arranged this way.

**On a Linux VM**, the same file is *copied into the store* and is read-only.
The VM has no checkout of this repo, so a symlink would dangle.

One source, two delivery modes, selected by `deliveryMode` in the Nix code.

### The exception: generated files

A few files aren't delivered whole, because part of them differs per machine.
Git and jj identity are the examples — `andon` uses a work email.

For those, Nix generates a small file with the per-host part and layers it over
the editable body:

- `~/.config/git/config` — Nix writes the `[user]` block, then `[include]`s
  `home/dotfiles/config/git/config-body`, which you edit freely
- `~/.config/jj/conf.d/00-identity.toml` — Nix writes it;
  `50-main.toml` is the editable body

So: **the identity is generated, the body is live.** Change the body freely.
Changing identity means editing Nix and re-applying.

---

## 6. Which command applies my change

Two commands. Picking the wrong one wastes time but breaks nothing.

![Activation](diagrams/activation.svg)

```bash
make home    # user tier: packages + dotfiles. No sudo. Seconds.
make         # system tier: Homebrew, macOS defaults, launchd. Sudo. Slow.
```

**Most changes need neither.** Editing the body of an existing dotfile is live
immediately — just commit it.

| You changed | Run |
| --- | --- |
| Body of a managed dotfile | nothing; commit it |
| A package in `home/packages/` | `make home` |
| Added a *new* dotfile | `make home` |
| Anything in `modules/` or `hosts/` | `make` |
| Homebrew apps | `make` |

`make home` is safe to run whenever you're unsure. It's idempotent and needs no
sudo.

---

## 7. Cookbook

**Add a command-line tool**

```bash
# 1. find the attribute name
nix search nixpkgs ripgrep
# 2. add it to the list in home/packages/workstation.nix
# 3. apply
make home
```

**Change your shell config**

```bash
$EDITOR /etc/nix-darwin/home/dotfiles/bashrc
# already live in a new shell — nothing to run
```

**Add a Mac app**

```bash
# add the cask to modules/darwin/homebrew.nix, then
make
```

**Check a change before applying**

```bash
nix flake check --no-build          # evaluates everything
darwin-rebuild build --flake .#io   # builds the system, doesn't apply it
```

**Undo**

```bash
home-manager generations            # list; then run the path shown with /activate
sudo darwin-rebuild --rollback      # system tier
```

**See what a change actually did**

```bash
nix eval .#homeConfigurations.\"paul@io\".config.home.packages --apply 'x: builtins.length x'
```

---

## 8. Rules that will bite you

**Use `jj`, never `git`.** This repo is managed with Jujutsu. `jj describe -m`,
`jj new`, `jj log`. Always pass `-m` — jj opens an editor otherwise. `jj git
push` and `jj git fetch` are fine; those are the interop layer.

**`nix flake check --no-build`, never bare `nix flake check`.** The bare form
tries to *build* the Linux VM configurations, which needs a builder that isn't
always reachable. It'll fail for reasons unrelated to your change.

**Never `nix profile install`.** It puts a package in the same profile Home
Manager manages, and the next `make home` fails with a collision. Add it to
`home/packages/` instead. The profile should stay empty.

**`sudo` needs Touch ID here**, so `make` can't run unattended, and can't run
over SSH.

**Homebrew never uninstalls.** `cleanup = "none"` is set deliberately.
Removing a cask from the Nix file stops it being *managed*; it doesn't remove
it from the machine. Uninstall by hand if you mean it.

---

## 9. Troubleshooting

**`bash: /etc/profiles/per-user/paul/bin/<tool>: No such file or directory`**

Stale path cached by your shell. Run `hash -r`, or open a new shell.

**`make home` → `home-manager: command not found`**

The CLI comes from the profile it installs, so a first-time or post-failure run
has to bootstrap:

```bash
nix run home-manager -- switch --flake ".#paul@$(hostname)" -b hm-bak
```

**Activation aborts: "Existing file is in the way"**

Home Manager won't clobber a file it doesn't manage. `-b hm-bak` moves it aside
as `<name>.hm-bak`. The `make home` target already passes this.

**`brew bundle` fails partway**

Homebrew runs last in a system switch, so everything else already succeeded —
the system is correctly configured and only Homebrew is incomplete. Re-run
`make`; `brew bundle` is idempotent. A disabled or renamed cask needs fixing in
`modules/darwin/homebrew.nix`.

**A build takes 15 minutes instead of 3 seconds**

A flake input moved and something is compiling from source — usually `jj`,
which tracks its main branch. Expected after `make update`, not a fault.

---

## 10. Glossary

| Term | Meaning |
| --- | --- |
| **derivation** | A build recipe. Evaluating one ≠ building it. |
| **store path** | `/nix/store/<hash>-<name>`, read-only, content-addressed. |
| **profile** | A symlink farm of installed packages. |
| **generation** | One numbered version of a profile. Rollback target. |
| **flake** | A pinned, reproducible project definition. |
| **overlay** | A patch to the package set — adds or modifies a package. |
| **module** | A file contributing options to a configuration. |
| **darwinConfiguration** | The system tier for a Mac. Needs sudo. |
| **homeConfiguration** | The user tier. No sudo. |
| **`isVibium`** | Flag marking the work machine, gating personal apps. |
| **`deliveryMode`** | `"symlink"` (Mac, live) or `"store"` (VM, frozen). |

---

## 11. Your first day

1. `cd /etc/nix-darwin && ls` — read `flake.nix` top to bottom. It's short.
2. Open `home/packages/workstation.nix`. That's what's installed for the user.
3. Add a tool you like, run `make home`, confirm it's on `PATH`.
4. Edit `home/dotfiles/bashrc`, open a new shell, watch it already be there.
5. Commit both with `jj describe -m "..."` and `jj new`.

If you understand why steps 3 and 4 need different amounts of work, you
understand this repo.
