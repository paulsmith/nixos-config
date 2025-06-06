{
  description = "NixOS (and nix-darwin) configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      darwin,
      home-manager,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#paulsmith-HJ6D3J627M
      darwinConfigurations."paulsmith-HJ6D3J627M" =
        let
          username = "paulsmith";
          system = "aarch64-darwin";
        in
        darwin.lib.darwinSystem {
          modules = [
            (import ./hosts/paulsmith-HJ6D3J627M/configuration.nix { inherit username; })
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/${username}/home.nix ({
                unstable-pkgs = (import inputs.nixpkgs-unstable { inherit system; });
              });
            }
          ];
        };
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#io
      darwinConfigurations."io" =
        let
          username = "paul";
          nextdnsProfile = "d3b8fa";
          system = "aarch64-darwin";
        in
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            # Pin registry entries
            {
                nix.registry.nixpkgs.flake = nixpkgs;
                nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
            }
            (import ./hosts/io/configuration.nix {
              inherit username nextdnsProfile;
              hostname = "io";
            })
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/${username}/home.nix ({
                unstable-pkgs = (import inputs.nixpkgs-unstable { inherit system; });
              });
            }
          ];
        };
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#oberon
      darwinConfigurations."oberon" =
        let
          username = "paul";
          nextdnsProfile = "d3b8fa";
          system = "aarch64-darwin";
        in
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            # Pin registry entries
            {
                nix.registry.nixpkgs.flake = nixpkgs;
                nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
            }
            (import ./hosts/oberon/configuration.nix {
              inherit username nextdnsProfile;
              hostname = "oberon";
            })
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/${username}/home.nix ({
                unstable-pkgs = (import inputs.nixpkgs-unstable { inherit system; });
              });
            }
          ];
        };
    };
}
