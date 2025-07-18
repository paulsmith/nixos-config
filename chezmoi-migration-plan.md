# Chezmoi Migration Plan for Nix Dotfiles

## Overview
This plan migrates frequently-edited dotfiles from home-manager to chezmoi while keeping package management and system configuration in Nix. The goal is to enable instant editing/testing of configs without waiting for Nix evaluation.

## Current State
- All dotfiles managed by home-manager in `/Users/paul/.config/nixos-config/`
- Two users: `paul` (personal) and `paulsmith` (work) with shared base configs
- Main pain point: ~30s+ Nix evaluation cycle for simple config changes
- Repository uses `jj` (Jujutsu) for version control, not git

## Migration Checklist

### Phase 1: Setup and Preparation

- [x] **Add chezmoi to Nix packages**
  - Add `chezmoi` to the appropriate package list in `users/paul/home.nix`
  - Also add to `users/paulsmith/home.nix` if needed
  - Run `make` to apply changes

- [x] **Initialize chezmoi repository**
  ```bash
  # Initialize chezmoi with a local repo first
  chezmoi init
  
  # Convert the chezmoi git repo to jj
  cd ~/.local/share/chezmoi
  jj git init --colocate
  ```

- [x] **Create chezmoi configuration**
  - Create `~/.config/chezmoi/chezmoi.toml` with appropriate settings
  - Configure it to respect the existing directory structure

### Phase 2: Migrate Neovim Configuration (Highest Priority)

- [x] **Prepare home-manager to stop managing Neovim config**
  - In `users/paul/home.nix`, comment out or remove the Neovim config file management
  - Look for: `home.file.".config/nvim".source = ../../common/nvim;`
  - Keep `programs.neovim.enable = true;` to ensure Neovim package stays installed

- [x] **Add Neovim config to chezmoi**
  ```bash
  # Add the entire nvim directory to chezmoi
  chezmoi add ~/.config/nvim
  ```

- [x] **Test the migration**
  - Make a small edit to `~/.config/nvim/init.lua`
  - Verify it takes effect immediately in Neovim
  - Commit the change in chezmoi: `cd ~/.local/share/chezmoi && jj commit -m "test nvim edit"`

### Phase 3: Migrate Shell Configuration

- [x] **Extract bash extras from home-manager**
  - Remove the `home.file` entries that source `common/bash/extra.bash`
  - Keep `programs.bash.enable = true` and basic settings in home-manager

- [x] **Add bash configuration to chezmoi**
  ```bash
  # Create a .bashrc.d directory approach
  mkdir -p ~/.bashrc.d
  cp /Users/paul/.config/nixos-config/common/bash/extra.bash ~/.bashrc.d/
  chezmoi add ~/.bashrc.d/extra.bash
  
  # Add sourcing to .bashrc if not managed by home-manager
  echo 'source ~/.bashrc.d/extra.bash' >> ~/.bashrc
  chezmoi add ~/.bashrc
  ```

### Phase 4: Migrate Git Configuration

- [x] **Update home-manager git config**
  - In `common/users/shared-user-config.nix`, remove `home.file` entries for:
    - `.config/git/ignore`
    - `.gitattributes`
  - Keep `programs.git.enable = true` and basic settings

- [x] **Add git files to chezmoi**
  ```bash
  chezmoi add ~/.config/git/ignore
  chezmoi add ~/.gitattributes
  ```

### Phase 5: Migrate User-Specific Configs with Templates

- [x] **Phase 5a: Set up chezmoi data configuration**
  - Create `~/.config/chezmoi/chezmoi.toml` data section for current user
  - Test `chezmoi data` command to verify configuration

- [x] **Phase 5b: Create jj config template**
  - Create template: `~/.local/share/chezmoi/dot_config/jj/config.toml.tmpl`
  - Test template rendering with `chezmoi execute-template`

- [x] **Phase 5c: Remove jj config from home-manager**
  - Remove the `home.file.".config/jj/config.toml"` entries from both user configs
  - Apply changes and test jj functionality

- [x] **Phase 5d: Apply and test jj template**
  - Run `chezmoi apply` to generate jj config from template
  - Test that jj uses correct email for commits

### Phase 6: Migrate Remaining Configurations

- [x] **Migrate Ghostty terminal config**
  - Remove from `common/users/shared-user-config.nix`
  - Add to chezmoi: `chezmoi add ~/Library/Application\ Support/com.mitchellh.ghostty/config`

- [x] **Migrate SQLite config**
  - Remove `.sqliterc` from home-manager
  - Add to chezmoi: `chezmoi add ~/.sqliterc`

- [x] **Migrate Hammerspoon (paul user only)**
  - Remove from `users/paul/home.nix`
  - Add to chezmoi: `chezmoi add ~/.hammerspoon`

- [x] **Migrate Claude config (paul user only)**
  - Remove from `users/paul/home.nix` (commented out)
  - Add to chezmoi: `chezmoi add ~/.claude/CLAUDE.md` (static config only)
  - Dynamic files (sessions, etc.) remain unmanaged

### Phase 7: Clean Up and Optimize

- [ ] **Review and clean up home-manager configs**
  - Ensure no duplicate file management between chezmoi and home-manager
  - Verify all `home.file` entries for migrated files are removed

- [ ] **Set up chezmoi ignore patterns**
  - Create `.chezmoiignore` to exclude OS-specific files on different systems

- [ ] **Document the new workflow**
  - Update the CLAUDE.md file to mention chezmoi for dotfile editing
  - Add notes about which configs are in chezmoi vs home-manager

### Phase 8: Testing and Validation

- [ ] **Test on each host**
  - Run `chezmoi apply` on each machine
  - Verify all configs work correctly
  - Test editing a file and running `chezmoi diff` before applying

- [ ] **Commit all changes**
  ```bash
  # In nixos-config repo
  jj commit -m "Remove dotfile management for chezmoi-managed files"
  
  # In chezmoi repo
  cd ~/.local/share/chezmoi
  jj commit -m "Initial dotfiles migration from home-manager"
  ```

## Important Notes for the Agent

1. **Version Control**: This repo uses `jj`, not `git`. Use `jj` commands for commits.
2. **Testing**: Always run `nix flake check` after modifying Nix files before running `make`.
3. **Chezmoi Philosophy**: Only migrate files that are frequently edited. Keep system-level configs in Nix.
4. **User Differences**: Remember there are two users (paul/paulsmith) with different emails but shared configs.
5. **macOS Paths**: Some configs like Ghostty use macOS-specific paths (`~/Library/Application Support/`).

## Success Criteria

- [ ] Can edit `~/.config/nvim/init.lua` and see changes immediately in Neovim
- [ ] Can modify bash aliases/functions without running `make`
- [ ] Nix still manages all package installations
- [ ] Both paul and paulsmith users work correctly with appropriate email configs
- [ ] No conflicts between chezmoi and home-manager