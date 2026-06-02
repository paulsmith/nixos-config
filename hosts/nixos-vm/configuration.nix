{ inputs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  networking.networkmanager.enable = true;

  virtualisation = {
    host.pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };

    memorySize = 2048;
    cores = 2;
  };
}
