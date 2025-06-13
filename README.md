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
- macOS window management (Hammerspoon)

## Structure

```
.
├── common/                   # Shared configurations
│   ├── bash/                 # Bash shell configuration
│   ├── hosts/                # Shared host configurations
│   ├── jj/                   # Jujutsu VCS configuration
│   ├── nvim/                 # Neovim configuration and plugins
│   └── users/                # Shared user configurations
├── hosts/                    # Host-specific configurations
│   ├── io/                   # Personal machine (laptop)
│   ├── oberon/               # Personal machine (desktop/workstation)
│   ├── paulsmith-HJ6D3J627M/ # Work laptop configuration
│   └── venus/                # Personal machine (older)
├── users/                    # User-specific configurations
│   ├── paul/                 # Personal user config
│   └── paulsmith/            # Work user config
├── flake.nix                 # Main Nix flake configuration
├── flake.lock                # Locked dependencies
└── Makefile                  # Build automation
```

## Hosts

### paulsmith-HJ6D3J627M (work machine)
Work-specific configuration with minimal applications and development tools needed for professional work.

### io (personal laptop)
Newer personal machine with essential applications and media tools.

### oberon (pershop desktop/workstation)
Full-featured personal desktop/workstation with extensive applications including:
- Creative tools (Blender, Inkscape, GIMP alternatives)
- Development environments
- Media applications (IINA, VLC, OBS)
- Productivity apps (Obsidian, LibreOffice)
- Gaming (Steam, TIC-80)

### venus (personal older laptop)
Older personal machine configuration with similar setup to io.

## Features

### System Configuration
- macOS system preferences and defaults
- Touch ID for sudo authentication
- Homebrew cask and formula integrations
- System package management
- Automatic garbage collection
- NextDNS integration (configurable)

### User Environment
- Shell configuration (Bash with custom prompt and integrations)
- Command-line tools and utilities
- Git and Jujutsu VCS configuration
- Development environments
- Terminal configuration (Ghostty with Iosevka Nerd Font)
- Hammerspoon window management (personal machines)

### Neovim Setup
My Neovim configuration includes:
- Custom key mappings and leader key (`,`)
- Plugin management with lazy.nvim
- LSP configuration for multiple languages (Go, Rust, Lua, Zig, C/C++)
- Treesitter for syntax highlighting
- Telescope for fuzzy finding
- Autocomplete with nvim-cmp and LuaSnip
- Code formatting with conform.nvim
- Git integration with gitsigns
- File browser with neo-tree
- Tokyo Night color scheme with automatic light/dark mode switching
- GitHub Copilot integration
- Undo tree visualization

### Hammerspoon Integration (Personal Machines)
- Clipboard history management with ClipboardTool
- Pomodoro timer integration (Tomito app)
- WiFi network automation with Tailscale
- Volume ejection shortcuts
- Configuration auto-reloading

### Development Tools
- Language support for Go, Rust, Python, Lua, Zig, and more
- Language servers for IDE-like functionality
- Git and GitHub CLI integration
- Jujutsu for advanced version control workflows
- Docker/container support (Colima)
- Various utilities for development workflows
- UV for Python package management

## Usage

### Setup

1. Install Nix with flakes support:
   ```bash
   curl -L https://nixos.org/nix/install | sh
   ```

2. Install nix-darwin:
   ```bash
   nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
   ./result/bin/darwin-installer
   ```

3. Clone this repository:
   ```bash
   git clone git@github.com:paulsmith/nixos-config.git ~/.config/nix-darwin
   cd ~/.config/nix-darwin
   ```

### Building & Applying Configuration

For the current hostname:
```bash
make
```

Or specify a specific host:
```bash
make io
make oberon
make paulsmith-HJ6D3J627M
```

### Updating

To update the unstable channel:
```bash
make update-unstable
```

## Custom Shell Features

This config includes custom shell enhancements:

- **Prompt**: Custom colored prompt showing directory and command status
- **Aliases**: `vi`/`vim`/`view` for neovim, Git shortcuts (`gs`, `gd`, `gco`, etc.)
- **Functions**: `t` for creating temporary directories
- **Integrations**:
  - Ghostty shell integration
  - UV completion for Python
  - Direnv for project environments

## Package Management

The configuration uses a hybrid approach:
- **Nix packages**: Core development tools, CLI utilities, and system packages
- **Homebrew casks**: GUI applications, Mac-specific tools, and some specialized software
- **Unstable packages**: Latest versions of rapidly evolving tools (Go, Neovim, Jujutsu)

## Notes

- The configuration pins Nix versions to ensure reproducibility
- Automatic garbage collection runs weekly to manage disk space
- SSH keys are configured for inter-machine access
- Service management is handled via runit on personal machines
- Font configuration uses Iosevka Term Nerd Font for consistent terminal display

## Credits

This configuration is assembled from my personal preferences and draws inspiration from various Nix community configurations.
