{
  description = "NixOS (and nix-darwin) configuration by paulsmith";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, darwin, home-manager, ... }: {
    nixpkgs.config.allowUnfree = true;
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#paulsmith-HJ6D3J627M
    darwinConfigurations."paulsmith-HJ6D3J627M" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/paulsmith-HJ6D3J627M/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.paulsmith = import ./users/paulsmith/home.nix;
        }
      ];
    };
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#venus
    darwinConfigurations."venus" = let
      username = "paul";
      nextdnsProfile = "d3b8fa";
      system = "aarch64-darwin";
    in darwin.lib.darwinSystem {
      inherit system;
      modules = [
        (import ./hosts/venus/configuration.nix {
          inherit username nextdnsProfile;
          hostname = "venus";
        })
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.paul = import ./users/paul/home.nix ({
            unstable-pkgs =
              (import inputs.nixpkgs-unstable { inherit system; });
          });
        }
      ];
    };
  };
}
