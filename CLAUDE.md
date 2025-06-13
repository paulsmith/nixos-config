# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

- `make` or `make all` - Build and apply Nix configuration for current hostname
- `make <hostname>` - Build specific host (e.g., `make io`, `make oberon`, `make paulsmith-HJ6D3J627M`)
- `make update-unstable` - Update unstable nixpkgs channel

## Validation Commands

Use these commands to validate changes before expensive rebuilds:
- `nix flake check` - Validate flake syntax and configuration semantics
- `nix flake show` - Display flake outputs structure
- `darwin-rebuild build --flake .#<hostname>` - Build without switching (faster validation)

**Important**: Always use `nix flake check` after configuration changes to catch syntax errors early. Only run `darwin-rebuild switch` or `make` when you're confident the configuration is correct, as these require sudo and take time to complete.

## Architecture Overview

This is a Nix configuration repository using nix-darwin and home-manager for macOS system management. The architecture follows a modular approach:

### Core Structure
- **flake.nix**: Main entry point defining all system configurations with inputs from nixpkgs (24.11), nixpkgs-unstable, nix-darwin, and home-manager
- **Makefile**: Simple build automation using `darwin-rebuild switch --flake`
- **Two-tier configuration**: Host configurations import shared configs, user configurations layer on top

### Configuration Layers
1. **Shared host config** (common/hosts/shared-host-config.nix): Base system settings, nix daemon, Touch ID sudo
2. **Host-specific configs** (hosts/*/configuration.nix): Machine-specific settings, homebrew packages, NextDNS profiles
3. **Shared user config** (common/users/shared-user-config.nix): Shell aliases, git config, direnv, ghostty terminal
4. **User-specific configs** (users/*/home.nix): Personal package lists, development tools

### Key Design Patterns
- **Unstable packages**: Latest versions of rapidly evolving tools (Go, Neovim, Jujutsu) sourced from nixpkgs-unstable
- **Hybrid package management**: Nix for CLI tools/development, Homebrew for GUI apps
- **Environment isolation**: Uses direnv for project-specific environments
- **Font consistency**: Iosevka Term Nerd Font across all terminal configurations

### Host Profiles
- **paulsmith-HJ6D3J627M**: Work machine with minimal application set
- **io/oberon/venus**: Personal machines with full creative and development toolsets

## Development Environment

This configuration provides:
- **Neovim**: Fully configured with LSP (Go, Rust, Lua, Zig, C/C++), plugins managed by lazy.nvim
- **Shell**: Bash with custom prompt, extensive aliases (vi→nvim, git shortcuts)
- **VCS**: Git + Jujutsu for advanced workflows
- **Languages**: Go, Rust, Python (UV), Lua, with corresponding LSPs and formatters
- **Containers**: Colima for Docker workflows
- **Services**: runit for service management on personal machines

## File Organization

Common configurations are shared across hosts/users through imports. Host-specific overrides handle machine differences (work vs personal, different hardware). User profiles separate work (paulsmith) from personal (paul) contexts.
