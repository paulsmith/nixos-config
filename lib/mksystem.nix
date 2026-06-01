{
  nixpkgs,
  overlays,
  inputs,
  configurationRevision,
}:

name:

{
  system ? "aarch64-darwin",
  user,
  isVibium ? false,
  nextdnsProfile ? null,
}:

let
  lib = nixpkgs.lib;

  isDarwin = system: nixpkgs.lib.hasSuffix "-darwin" system;
  isLinux = !isDarwin system;
  platform = if isDarwin system then "darwin" else "nixos";

  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  platformConfig = ../modules/${platform}/common.nix;
  hostConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = ../users/${user}/${platform}.nix;

  systemFn = if isLinux then nixpkgs.lib.nixosSystem else inputs.darwin.lib.darwinSystem;
in
systemFn {
  inherit system;

  specialArgs = {
    inherit
      inputs
      configurationRevision
      isVibium
      nextdnsProfile
      unstablePkgs
      ;
    hostname = name;
    username = user;
  };

  modules = [
    {
      nixpkgs = {
        overlays = overlays;
        config.allowUnfree = true;
      };
    }
    ../modules/packages.nix
    platformConfig
    hostConfig
    userOSConfig
  ];
}
