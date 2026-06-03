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
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "git+ssh://git@github.com/paulsmith/dotfiles.git";
      flake = false;
    };
    go-overlay.url = "github:purpleclay/go-overlay";
    jj.url = "github:martinvonz/jj";
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        # nextdnsProfile = "8ce4cd"; # Wed Jun  3 12:12:24 CDT 2026 still debugging this
      };

      darwinConfigurations.io = mkSystem "io" {
        user = "paul";
        nextdnsProfile = "d3b8fa";
      };

      darwinConfigurations.oberon = mkSystem "oberon" {
        user = "paul";
        nextdnsProfile = "d3b8fa";
      };

      nixosConfigurations.nixos-vm = mkSystem "nixos-vm" {
        user = "paul";
        system = "aarch64-linux";
        packageProfile = "vm";
      };

      nixosConfigurations.agent-vm = mkSystem "agent-vm" {
        user = "paul";
        system = "aarch64-linux";
        packageProfile = "vm";
      };

      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
