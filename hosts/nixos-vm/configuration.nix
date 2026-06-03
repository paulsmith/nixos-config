{
  pkgs,
  inputs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  boot.kernelParams = [ "quiet" ];

  networking.networkmanager.enable = true;

  virtualisation = {
    host.pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };

    memorySize = 1024;
    cores = 2;
  };

  environment.systemPackages = with pkgs; [
    cowsay
    ponysay
  ];
}
