# NixOS and nix-darwin config

## Build Commands

- `make` or `make all` - Build and apply Nix configuration for current hostname
- `make <hostname>` - Build specific host (e.g., `make io`, `make oberon`, `make paulsmith-HJ6D3J627M`)
- `make update` - Update nixpkgs flake lock

## Validation Commands

Use these commands to validate changes before expensive rebuilds:
- `nix flake check` - Validate flake syntax and configuration semantics
- `nix flake show` - Display flake outputs structure
- `darwin-rebuild build --flake .#<hostname>` - Build without switching (faster validation - do this before committing and moving on to a new change, even if you think the syntax is valid from check or show)

**Important**: Always use `nix flake check` after configuration changes to catch syntax errors early. Only run `darwin-rebuild switch` or `make` when you're confident the configuration is correct, as these require sudo and take time to complete.

## Source code control

This repo is managed with `jj` (jujutsu), not `git`.
