{ hostname, pkgs, ... }:

{
  networking.hostName = hostname;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "26.05";
}
