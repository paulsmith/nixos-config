# My Nix Configuration

This repository contains my personal Nix configuration for managing macOS systems using nix-darwin and home-manager.

## Overview

This configuration manages:
- System settings via nix-darwin
- User environment via home-manager
- Application installations via both Nix and Homebrew
- Development tools and utilities
- Neovim configuration with plugins
- Terminal environment (Ghostty)

## Structure

```
.
├── common/                   # Shared configurations
│   ├── hosts/                # Shared host configurations
│   ├── nvim/                 # Neovim configuration and plugins
│   └── users/                # Shared user configurations
├── hosts/                    # Host-specific configurations
│   ├── paulsmith-HJ6D3J627M/ # Work laptop configuration
│   └── venus/                # Personal machine configuration
├── users/                    # User-specific configurations
│   ├── paul/                 # Personal user config
│   └── paulsmith/            # Work user config
├── flake.nix                 # Main Nix flake configuration
└── flake.lock                # Locked dependencies
```

## Features

### System Configuration

- macOS system preferences and defaults
- Touch ID for sudo authentication
- Homebrew cask and formula integrations
- System package management

### User Environment

- Shell configuration (Bash)
- Command-line tools and utilities
- Git configuration
- Development environments
- Terminal configuration (Ghostty)

### Neovim Setup

My Neovim configuration includes:

- Custom key mappings
- Plugin management with lazy.nvim
- LSP configuration for multiple languages
- Treesitter for syntax highlighting
- Telescope for fuzzy finding
- Autocomplete with nvim-cmp
- Code formatting with conform.nvim
- Git integration with gitsigns
- File browser with neo-tree
- Tokyo Night color scheme

### Development Tools

- Language support for Go, Rust, Python, Lua, Zig, and more
- Language servers for IDE-like functionality
- Git and GitHub CLI integration
- Docker/container support
- Various utilities for development workflows

## Usage

### Setup

1. Install Nix:
   ```
   curl -L https://nixos.org/nix/install | sh
   ```

2. Install nix-darwin:
   ```
   nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
   ./result/bin/darwin-installer
   ```

3. Clone this repository:
   ```
   git clone https://github.com/yourusername/nix-config.git ~/.nixpkgs
   cd ~/.nixpkgs
   ```

### Building & Applying Configuration

For the first time:
```
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

To apply changes:
```
make
```

Or specify a specific host:
```
make venus
```

### Updating

To update the unstable channel:
```
make update-unstable
```

## Custom Commands

This config includes some custom shell commands and helpers:

- `vi`, `vim`, `view` aliases for neovim
- Git shortcuts like `gs`, `gd`, `gco`, etc.
- `dev` command to initialize development environments
- `push-main` for Jujutsu git workflow

## Hosts

### paulsmith-HJ6D3J627M (Work Machine)

Work-specific configuration with development tools and applications needed for my professional work.

### venus (Personal Machine)

Personal machine with additional multimedia applications, macOS integrations, and personal development tools.

## Credits

This configuration is assembled from my personal preferences and with inspiration from various Nix community configurations.