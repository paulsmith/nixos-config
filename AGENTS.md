# NixOS and nix-darwin config

## Build Commands

- `make` - Build and apply Nix configuration for current hostname
- `HOSTNAME=<foo> make` - Build specific host
- `make update` - Update flake lock

## Validation Commands

Use these commands to validate changes before expensive rebuilds:
- `nix flake check` - Validate flake syntax and configuration semantics
- `nix flake show` - Display flake outputs structure
- `darwin-rebuild build --flake .#<hostname>` - Build without switching (faster validation - do this before committing and moving on to a new change, even if you think the syntax is valid from check or show)

**Important**: Always use `nix flake check` after configuration changes to catch syntax errors early. Only run `darwin-rebuild switch` or `make` when you're confident the configuration is correct, as these require sudo and take time to complete.

## Source code control

This repo is managed with `jj` (jujutsu), not `git`.

## NixOS VMs From macOS nix-darwin

When adding a NixOS VM host on Apple Silicon macOS:

- Prefer `nix-rosetta-builder` for local Linux builds.
- Bootstrap it with temporary host-scoped `nix.linux-builder.enable = true;`, then replace that with `inputs.nix-rosetta-builder.darwinModules.default` plus `nix-rosetta-builder.onDemand = true;`.
- Verify the builder with an `aarch64-linux` `uname -a` derivation before building NixOS systems.
- For VM hosts, import `${modulesPath}/virtualisation/qemu-vm.nix`.
- Set `virtualisation.host.pkgs` to an `aarch64-darwin` nixpkgs import so `system.build.vm` produces a Darwin-runnable QEMU script.
- Put `virtualisation.memorySize` and `virtualisation.cores` at top level for direct `config.system.build.vm` builds.
- Before running the VM, verify `result/bin/run-*-vm` uses Mach-O QEMU and `accel=hvf:tcg`.

<!-- BEGIN KATA (managed by `kata init --with-agents`) -->
## kata issue tracker

This project uses [kata](https://github.com/kenn-io/kata) as its shared issue
ledger. Run `kata quickstart` at the start of each session for the full agent
contract. The short version:

- Search before creating: `kata search "<keywords>" --agent`.
- Prefer updating existing issues over duplicates (`kata comment`, `kata label add`, `kata edit`).
- Default to `--agent` for ordinary reads and mutations; use `--json` only when a script needs structured data.
- Close only verified work: `kata close <ref> --done --message "<scope + verification>" --commit <sha>`.
- If work is incomplete, label `needs-review` and comment what remains rather than closing.
- Never `kata delete` or `kata purge` without explicit user authorization.
<!-- END KATA -->
