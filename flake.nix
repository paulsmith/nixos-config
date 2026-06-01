{
  description = "NixOS (and nix-darwin) configuration by paulsmith";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    go-overlay.url = "github:purpleclay/go-overlay";
    jj.url = "github:martinvonz/jj";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSystem =
        fn:
        nixpkgs.lib.genAttrs allSystems (
          system:
          fn {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );

      configurationRevision = self.rev or self.dirtyRev or null;

      overlays = [
        inputs.go-overlay.overlays.default
        inputs.jj.overlays.default
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit
          nixpkgs
          overlays
          inputs
          configurationRevision
          ;
      };
    in
    {
      darwinConfigurations.andon = mkSystem "andon" {
        user = "paul";
        isVibium = true;
      };

      darwinConfigurations.io = mkSystem "io" {
        user = "paul";
      };

      darwinConfigurations.oberon = mkSystem "oberon" {
        user = "paul";
      };

      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
