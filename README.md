# NixOS and nix-darwin Configurations

This repository contains my personal Nix configuration for managing NixOS systems and macOS systems with nix-darwin.

## Usage

### Setup

1. Install Nix with flakes support (via [Lix installer](https://lix.systems/install/)):
   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

#### macOS - nix-darwin

2. Clone this repository:
   ```bash
   git clone git@github.com:paulsmith/nixos-config.git /etc/nix-darwin
   cd /etc/nix-darwin
   ```

3. Install nix-darwin:
   ```bash
   sudo nix run nix-darwin/master#darwin-rebuild -- switch
   ```

4. Using nix-darwin:
   ```bash
   sudo darwin-rebuild switch
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
make andon
```

### Updating

```bash
make update
```
