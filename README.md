# NixOS and nix-darwin Configurations

This repository contains my personal Nix configuration for macOS systems managed
with nix-darwin, plus a small NixOS VM.

Active flake outputs:

- Darwin hosts: `andon`, `io`, `oberon`
- NixOS hosts: `nixos-vm`

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

## Building and Applying

Apply the configuration for the current hostname:

```bash
make
```

Apply the configuration for a specific Darwin host:

```bash
HOSTNAME=io make
HOSTNAME=oberon make
HOSTNAME=andon make
```

Build without switching:

```bash
darwin-rebuild build --flake .#io
```

## Validation

Run these checks after configuration changes:

```bash
nix flake check
nix flake show
darwin-rebuild build --flake .#<hostname>
```

Use `darwin-rebuild build` before committing a Darwin configuration change, even
when `nix flake check` succeeds.

## NixOS VM

The VM is exposed as `nixosConfigurations.nixos-vm`. It is an `aarch64-linux`
NixOS guest built from `hosts/nixos-vm/configuration.nix` with the `vm` package
profile.

On Apple Silicon macOS, building the VM requires an `aarch64-linux` builder.
The `andon` host currently enables `nix-rosetta-builder.onDemand = true` for
that purpose.

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

Useful VM overrides:

```bash
VM_SSH_HOST=2223 make vm-run
VM_SSH_HOST=2223 make vm-ssh
VM_DISK=/tmp/nixos-vm.qcow2 make vm-run
```

The VM currently gets `virtualisation.memorySize = 2048`,
`virtualisation.cores = 2`, NetworkManager, OpenSSH, and a pared-down package
set from `modules/packages/vm.nix`.

## Updating

```bash
make update
```
