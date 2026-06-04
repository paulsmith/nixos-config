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
  packageProfile ? "workstation",
}:

let
  lib = nixpkgs.lib;

  isDarwin = system: lib.hasSuffix "-darwin" system;
  isLinux = !isDarwin system;
  platform = if isDarwin system then "darwin" else "nixos";

  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  packageProfiles = {
    workstation = [
      ../modules/packages/core.nix
      ../modules/packages/workstation.nix
    ];
    vm = [
      ../modules/packages/core.nix
      ../modules/packages/vm.nix
    ];
  };

  platformConfig = ../modules/${platform}/common.nix;
  hostConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = ../users/${user}/${platform}.nix;

  systemFn = if isLinux then lib.nixosSystem else inputs.darwin.lib.darwinSystem;
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

  modules =
    lib.optionals (isDarwin system) [
      inputs.nix-rosetta-builder.darwinModules.default
    ]
    ++ packageProfiles.${packageProfile}
    ++ [
      {
        nixpkgs = {
          overlays = overlays;
          config.allowUnfree = true;
        };
      }
      ../users/ssh-pubkeys.nix
      platformConfig
      hostConfig
      userOSConfig
    ];
}
