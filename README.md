# NixOS and nix-darwin Configurations

This repository contains my personal Nix configuration for macOS systems managed
with nix-darwin, plus a small NixOS VM.

Active flake outputs:

- Darwin hosts (system tier): `io`, `oberon`
- Home Manager (user tier): `paul@io`, `paul@oberon`
- NixOS hosts: `nixos-vm`, `agent-vm`

Dotfiles live in `home/dotfiles/` and are symlinked into `$HOME` from this
working tree, so editing one takes effect immediately with no rebuild. See
`docs/manual/` for the full explanation.

This repository is managed with `jj` (Jujutsu). The remote is Git-backed, so a
plain `git clone` is still useful for bootstrapping a new machine, but use `jj`
for normal source control work inside the checkout.

## Setup

1. Install Nix with flakes support. The Lix installer is one option:

   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

2. Clone the repository:

   ```bash
   git clone git@github.com:paulsmith/nixos-config.git /etc/nix-darwin
   cd /etc/nix-darwin
   ```

3. Bootstrap nix-darwin for the current host:

   ```bash
   sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ".#$(hostname)"
   ```

4. Bootstrap Home Manager. The `home-manager` CLI comes from the profile it
   installs, so the first activation has to go through `nix run`:

   ```bash
   nix run home-manager -- switch --flake ".#$(id -un)@$(hostname)" -b hm-bak
   ```

   Order matters: the repo must exist at `/etc/nix-darwin` before this runs, or
   the dotfile symlinks point at nothing.

5. Site-local values that are deliberately not in the repo. The Hammerspoon
   WiFi watcher reads them from `~/.hammerspoon/private.lua`, and stays inert
   if the file is absent:

   ```lua
   return {
     homeSSID = "...",
     exitNode = "...",
   }
   ```

## Building and Applying

Two tiers, two commands:

```bash
make home   # user: packages and dotfiles. No sudo. Seconds.
make        # system: Homebrew, macOS defaults, launchd. Sudo. Slow.
```

Editing the body of a dotfile already under `home/dotfiles/` needs neither —
it is live in the next shell. Run `make home` when adding a new file or
changing packages.

Target a specific host:

```bash
HOSTNAME=oberon make
HOME_TARGET=paul@oberon make home
```

Build without switching:

```bash
darwin-rebuild build --flake .#io
```

## Validation

Run these checks after configuration changes:

```bash
nix flake check --no-build
darwin-rebuild build --flake .#<hostname>
```

Use `--no-build`. Bare `nix flake check` tries to *build* the `aarch64-linux`
VM configurations, which needs a Linux builder that is not always reachable, so
it fails for reasons unrelated to your change.

Run `darwin-rebuild build` before committing a Darwin configuration change,
even when the flake check succeeds.

## NixOS VM

The VM is exposed as `nixosConfigurations.nixos-vm`. It is an `aarch64-linux`
NixOS guest built from `hosts/nixos-vm/configuration.nix`.

On Apple Silicon macOS, building the VM requires an `aarch64-linux` builder.
The `oberon` host enables `nix-rosetta-builder.onDemand = true` for that
purpose.

Build the VM:

```bash
make vm-build
```

Run the VM:

```bash
make vm-run
```

`make vm-run` builds first, stores the persistent disk at
`./.var/nixos-vm.qcow2`, runs the generated `result/bin/run-nixos-vm-vm`
script with `-nographic`, and forwards host port `2222` to guest SSH port `22`.

After the guest has booted, SSH into it:

```bash
make vm-ssh
```

VM SSH uses a repo-local passwordless key at `./.var/nixos-vm_ed25519`.
Generate it explicitly with:

```bash
make vm-ssh-key
```

For a VM that is already running and does not have that public key yet,
bootstrap it once:

```bash
make vm-ssh-bootstrap-key
```

This one-time bootstrap uses your normal SSH authentication path, so it may ask
Secretive for Touch ID once. After that, `make vm-ssh`, `make vm-deploy`, and
`make vm-guest-switch` use the VM-local key with `IdentityAgent=none`, so they
do not ask Secretive for SSH authentication.

VM SSH uses a repo-local known-hosts file at `./.var/known_hosts` instead of
`~/.ssh/known_hosts`. New VM host keys are accepted automatically for this VM
only, and stale keys can be removed without editing your normal SSH
known-hosts file:

```bash
make vm-ssh-reset-key
```

Update the running VM from the host:

```bash
make vm-deploy
```

`vm-deploy` uses `nixos-rebuild` from the repo's pinned `nixpkgs`, connects to
the guest over SSH, copies the built system closure, and activates it with
remote `sudo`. By default, it asks for the guest sudo password when activation
needs it.

Ship this checkout into the guest and switch from inside the VM:

```bash
make vm-guest-switch
```

`vm-guest-switch` first copies the working tree to `/home/paul/nixos-config` in
the guest, excluding local VCS/build artifacts, then runs:

```bash
sudo nixos-rebuild switch --flake .#nixos-vm
```

For kernel, initrd, or other next-boot changes, rebuild the host-side VM runner
with `make vm-build` before launching the VM again.

Useful VM overrides:

```bash
VM_SSH_HOST=2223 make vm-run
VM_SSH_HOST=2223 make vm-ssh-bootstrap-key
VM_SSH_HOST=2223 make vm-ssh
VM_SSH_HOST=2223 make vm-ssh-reset-key
VM_SSH_HOST=2223 make vm-deploy
VM_SSH_KEY=/tmp/nixos-vm_ed25519 make vm-ssh-key
VM_DISK=/tmp/nixos-vm.qcow2 make vm-run
VM_CONFIG_DIR=/home/paul/src/nixos-config make vm-guest-switch
VM_REBUILD_ACTION=test make vm-deploy
VM_REBUILD_SUDO='--sudo' make vm-deploy
```

The VM currently gets `virtualisation.memorySize = 1024`,
`virtualisation.cores = 2`, NetworkManager, OpenSSH, and a pared-down package
set from `home/packages/vm.nix`.

Unlike the Macs, the VMs receive dotfiles as read-only copies in the Nix store
rather than symlinks, since they have no checkout of this repository.

## Remotes

`origin` (GitHub) is authoritative. `bunny` is a locally-reachable mirror on the
NAS, kept in step manually and force-pushed when it diverges:

```bash
jj git push --remote origin -b main
jj git push --remote bunny  -b main
```

## Updating

```bash
make update
```

`make update` moves every flake input. Two of them — `jj`, which tracks its own
main branch, and `herdr` — build from source with no binary cache, so an update
that moves either costs roughly fifteen minutes of Rust compilation. A warm
rebuild that moves nothing takes about two seconds.
