# Unify system configuration: chezmoi + nix-darwin → Home Manager

Status: approved design, ready for implementation planning
Date: 2026-08-27

## Problem

System configuration is split across two repositories with two tools:

- `/etc/nix-darwin` (jj → `github:paulsmith/nixos-config`, **public**) — nix-darwin
  flake covering Darwin hosts `io`, `oberon`, `andon` plus `nixos-vm` and
  `agent-vm`.
- `~/.local/share/chezmoi` (jj → `ssh://bunny/media/nas/repo/dotfiles.git`,
  mirrored to `github:paulsmith/dotfiles`, **private**) — 38 managed dotfiles
  plus the `brew bundle` script.

The split originally bought fast dotfile edits: chezmoi applies a changed file
instantly, where `darwin-rebuild switch` does not. The costs have accumulated:

1. **Two Homebrew manifests fight each other.** `users/paul/darwin.nix` sets
   `homebrew.onActivation.cleanup = "uninstall"` over 1 brew, 14 casks and 1 mas
   app. `run_onchange_before_install-packages-darwin.sh.tmpl` runs `brew bundle`
   over a much larger, disjoint set. Every switch uninstalls the chezmoi set.
   Confirmed on `io`: `brew leaves` is down to `cowsay`; qemu, docker,
   karabiner-elements, Xcode and ~30 mas apps are gone.
2. **The dotfiles repo has forked.** Common ancestor `dde1191c` (2026-05-18),
   with real commits on both sides — five on GitHub, six on bunny — plus a third
   copy pinned in `flake.lock` at `79d3f3b8`, older than either.
3. **Nothing is in one place.** Two repos, two remotes, two sync paths, across
   three Macs.

## Constraints and decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Dotfile edit speed | All user dotfiles get a zero-rebuild path | Shell/editor, agent/tool, and app-config tiers were all selected as needing it |
| Homebrew | Merge both manifests into Nix, `cleanup = "none"` | Nix guarantees presence, never uninstalls; ad-hoc `brew install` survives |
| Repository | One repo — fold dotfiles into public `nixos-config`, after a secret audit | Retires the fork and the two-remote drift permanently |
| Backup remote | `bunny` retained as a second remote on `nixos-config`, force-pushed when diverged | Locally-accessible mirror of GitHub |
| Mechanism | Two-tier: out-of-store symlinks for bodies, generated store files for per-host identity | Instant edits where they matter, Nix generation where it earns its keep |
| `runit` | `pkgs.runit` + a launchd agent; drop `brew "runit"` | Declarative, and consistent with how the NixOS side already supervises services |
| Docker | Dropped | Colima was removed last commit; no runtime has been missed since |
| `andon` (work machine) | Personal Homebrew list gated on `isVibium` | Mirrors existing `isVibium` gating of SSH keys |

## Target architecture

```
/etc/nix-darwin/
  flake.nix                    # + home-manager wired into Darwin hosts
  lib/mksystem.nix             # + homeRepoRoot, deliveryMode
  hosts/…                      # unchanged
  modules/
    darwin/common.nix
    darwin/homebrew.nix        # NEW — moved out of users/paul/darwin.nix
    nixos/common.nix
    packages/…
  home/
    common.nix                 # HM config shared by all hosts and platforms
    darwin.nix                 #   Darwin-only
    linux.nix                  #   VM-only
    hosts/{io,oberon,andon}.nix
    dotfiles/                  # plain files, live-edited
      bashrc  bash_profile  inputrc  sqliterc
      gitattributes  gitignore_global  npmrc  tmux.conf
      claude/{CLAUDE.md,settings.json}
      config/git/config-body
      config/jj/50-main.toml
      config/nvim/{init.lua,lua/plugins/*.lua}
      config/{bat,fontconfig,karabiner}/…
      hammerspoon/…
      ghostty/config
  users/…
  docs/superpowers/specs/
```

### The two tiers

| | Live tier | Generated tier |
| --- | --- | --- |
| Mechanism | `config.lib.file.mkOutOfStoreSymlink` → repo path | store file rendered by Nix |
| Edit cost | zero — save and it is live | `home-manager switch` |
| Contents | every file under `home/dotfiles/` | ~4 per-host identity fragments |
| Rollback | `jj` | HM generations |

The generated tier is deliberately small:

- `~/.config/git/config` — sets `user.email` per host and
  `core.hooksPath = ${config.home.homeDirectory}/.config/git/hooks`, then
  `[include] path = …/home/dotfiles/config/git/config-body`.
- `~/.config/jj/conf.d/00-identity.toml` — per-host `user.email`.
  `~/.config/jj/conf.d/50-main.toml` is a live symlink.

jj config layering was verified empirically against jj 0.41.0: jj merges
`~/.config/jj/config.toml` and every `~/.config/jj/conf.d/*.toml`, in lexical
order, with no environment variable required.

This is how `andon` gets its `paul@vibium.com` identity without chezmoi
templating, and how the hardcoded `/Users/paul` in `core.hooksPath` is retired.

### Delivery mode is per-host

Workstations (`io`, `oberon`, `andon`) resolve the live tier against
`homeRepoRoot`. The VMs receive the *same* source files copied into the Nix
store — hermetic, no checkout required. One dotfile set, two delivery modes.
This retires `inputs.dotfiles`, its stale lock pin, and the `replaceStrings`
hacks in `users/paul/agent-home.nix`.

### File naming

chezmoi's `dot_`, `private_` and `empty_` prefixes are dropped; files take their
real names. No managed file requires 0600 — `private_dot_npmrc` is a single
`prefix=` line, and the karabiner and ghostty configs contain nothing sensitive.

### Homebrew

`modules/darwin/homebrew.nix`, `onActivation.cleanup = "none"`. The manifest is
the union of both existing lists. Both forks only *deleted* entries, so the
merge is a union of deletions:

| Item | Resolution |
| --- | --- |
| `ghostty` | **Excluded.** Nix declares it; chezmoi deliberately removed it ("need nightly tip for Golden Gate beta"). Declaring it would reinstall stable over the nightly. |
| `hammerspoon`, `Tomito` | Declared in both — deduped |
| `brew "mas"`, `brew "bash-completion"` | Dropped; `pkgs.mas` and `pkgs.bash-completion` already provide them |
| `brew "runit"` | Dropped in favour of `pkgs.runit` + launchd |
| `docker`, `docker-buildx`, `docker-compose` | Dropped |
| `swiftbar`, `Mic Drop`, `TypeIt4Me` | Stay removed |
| `Notchmeister` | Moves to `hosts/io/configuration.nix` via `homebrew.masApps` |

Taps: keep `1password/tap` and `ngrok/ngrok`. Drop `helix-editor/helix`
(`pkgs.helix` is in `workstation.nix`) and `nextdns/tap` (`services.nextdns` is
a nix-darwin module). `nikitabobko/tap` and `kenn-io/tap` are orphans — nothing
is installed from either (`kata` is a Go binary in `~/go/bin`) — so they go
undeclared. With `cleanup = "none"` no tap is removed; they simply stop being
asserted.

A proposed personal/work split is recorded below for review at Step 4; the
boundary is adjustable without reopening the design.

- **Personal only (`!isVibium`)** — casks: audacity, avifquicklook, discord,
  elmedia-player, gimp, iina, inkscape, kicad, libreoffice, musicbrainz-picard,
  rar, selfcontrol, slideshower. mas: Bike, Blackmagic Disk Speed Test, Brother
  P-touch Editor, File Viewer, Free Ruler, GarageBand, Hand Mirror, Hyperspace,
  iMovie, Ivory, Mimeo Photos, Nitro, Notchmeister, OneTab, Prime Video, Ruler,
  Steam Link, StopTheMadness, Tot, WhatsApp, WorldWideWeb.
- **Shared** — casks: 1password, 1password-cli, basictex, claude, cleanshot,
  codex-app, dangerzone, google-chrome, hammerspoon, handy, istat-menus,
  karabiner-elements, ngrok, obsidian, qlmarkdown, secretive, slack, utm. brews:
  cowsay, opam, qemu. mas: Kagi Search, Keynote, Microsoft Excel, Numbers,
  Pages, Swift Playground, TestFlight, Tomito, Xcode.

## Migration plan

**Step 0 — Reconcile the fork.** Merge GitHub and bunny into one tree. Three
files were touched on both sides: `run_onchange_…` (deleted by this migration),
`lazy-lock.json` (generated — regenerate with `:Lazy sync`), and `dot_bashrc`.
The bashrc conflict is a one-line judgment call: both sides independently fixed
the same pnpm bug, GitHub using `$HOME/Library/pnpm` with append ordering and
bunny using `/Users/paul/Library/pnpm` with prepend. Resolution: `$HOME`
(portable, required for the Linux VMs) with prepend ordering.

**Step 1 — Secret audit.** Read all 38 managed files end to end before anything enters
a public repository. Findings reported, not assumed. This is the gate on the
"audit then publish" decision; a single sensitive file changes the repository
visibility decision.

**Step 2 — Land the files.** Reconciled dotfiles into `home/dotfiles/` with
prefixes stripped. File moves only, no behaviour change.

**Step 3 — Wire Home Manager into Darwin.** `mksystem.nix` gains
`home-manager.darwinModules.home-manager`; add `home/{common,darwin,linux}.nix`
and per-host modules; select delivery mode per host.

> **The one dangerous moment.** chezmoi wrote *real files* into `$HOME`. Home
> Manager refuses to overwrite them and activation aborts. The first switch on
> each machine must set `home-manager.backupFileExtension = "hm-bak"` so
> originals are preserved rather than lost.

**Step 4 — Homebrew module.** Move, merge, `cleanup = "none"`, `isVibium`
split, tap audit.

**Step 5 — runit via launchd.** Replace `restart_service: :changed` with a
launchd agent supervising `runsvdir` against `$HOME/service`.

**Step 6 — Retire chezmoi.** Drop `pkgs.chezmoi` from `workstation.nix`, delete
the `run_onchange` script, retire `inputs.dotfiles` and the `replaceStrings`
hacks in `agent-home.nix`. Leave `ssh://bunny/media/nas/repo/dotfiles.git`
frozen in place as the rollback path — do not delete it.

**Step 7 — Roll out.** `io` → `oberon` → `andon`. Daily driver first, work
machine last, after two clean precedents.

**Step 8 — Backup remote.** Create `ssh://bunny/media/nas/repo/nixos-config.git`
and add it as a second remote on `/etc/nix-darwin`. Force-push when diverged;
GitHub remains authoritative.

## Verifications required during implementation

- `/etc/nix-darwin` must exist at that exact path on `oberon` and `andon`; the
  live tier resolves against it. If either differs, `homeRepoRoot` becomes
  per-host rather than a constant.
- `oberon` and `andon` may carry uncommitted chezmoi drift. `io` shows
  `MM .claude/settings.json`. Step 0 must account for all three.

## Out of scope

**Rebuild time after `make update`.** A warm `darwin-rebuild build` on `io` is
2.1 seconds. A cold one measured 14m23s, because `jj.url` tracks jj's *main
branch* and `herdr` builds from source, with `substituters` empty — so every
input bump forces a full Rust toolchain rebuild. This is a genuine recurring
cost, but it is unrelated to Home Manager and predates this split. Options for
a follow-up: pin `jj` to a release tag, use `pkgs.jujutsu`, or add a binary
cache.

**Moving `users.users.paul.packages` to `home.packages`.** A clean consolidation
that would also put package changes behind the faster `home-manager switch`, but
separable churn. Follow-up, not part of this migration.

## Rollback

Each step is independently revertible via `jj`. The frozen `dotfiles.git` on
bunny plus `*.hm-bak` files in `$HOME` mean the pre-migration state is
recoverable on every machine even after Step 6.
