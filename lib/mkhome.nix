{
  nixpkgs,
  overlays,
  inputs,
}: {
  hostname,
  email,
  system ? "aarch64-darwin",
  user ? "paul",
  isVibium ? false,
  homeRepoRoot ? "/etc/nix-darwin",
  deliveryMode ? "symlink",
}: let
  lib = nixpkgs.lib;

  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  platform =
    if lib.hasSuffix "-darwin" system
    then "darwin"
    else "linux";

  hostModule = ../home/hosts/${hostname}.nix;
in
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs = {
      inherit
        inputs
        unstablePkgs
        hostname
        isVibium
        email
        homeRepoRoot
        deliveryMode
        ;
      username = user;
    };

    modules =
      [
        ../home/common.nix
        ../home/${platform}.nix
      ]
      ++ lib.optional (builtins.pathExists hostModule) hostModule;
  }
