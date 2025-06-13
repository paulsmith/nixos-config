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
    let
      system = "aarch64-darwin";
      registryModule = {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
      };
      homeManagerModule = username: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = import ./users/${username}/home.nix ({
          unstable-pkgs = (import inputs.nixpkgs-unstable { inherit system; });
        });
      };

      makeDarwinConfig =
        {
          hostname,
          username,
          hostArgs ? { },
          includeRegistry ? true,
        }:
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            (import ./hosts/${hostname}/configuration.nix ({ inherit username; } // hostArgs))
            home-manager.darwinModules.home-manager
            (homeManagerModule username)
          ] ++ (if includeRegistry then [ registryModule ] else [ ]);
        };
    in
    {
      nixpkgs.config.allowUnfree = true;
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#paulsmith-HJ6D3J627M
      darwinConfigurations."paulsmith-HJ6D3J627M" = makeDarwinConfig {
        hostname = "paulsmith-HJ6D3J627M";
        username = "paulsmith";
        includeRegistry = false;
      };
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#io
      darwinConfigurations."io" = makeDarwinConfig {
        hostname = "io";
        username = "paul";
        hostArgs = {
          nextdnsProfile = "d3b8fa";
          hostname = "io";
        };
      };
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#oberon
      darwinConfigurations."oberon" = makeDarwinConfig {
        hostname = "oberon";
        username = "paul";
        hostArgs = {
          nextdnsProfile = "d3b8fa";
          hostname = "oberon";
        };
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
