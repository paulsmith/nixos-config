{
  description = "NixOS (and nix-darwin) configuration by paulsmith";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, darwin, home-manager, ... }: let
    user = "paulsmith";
  in
  {
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
            home-manager.users.${user} = import ./users/${user}/home.nix;
        }
      ];
    };
  };
}
