{ username }:
{ pkgs, ... }:
{
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.package = pkgs.nixVersions.nix_2_28;

  nix.settings.trusted-users = [
    "root"
    username
  ];

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = [
      "qemu"
      "runit"
      "gforth"
    ];
    casks = [
      "1password-cli"
      "docker"
      "ghostty"
      "inkscape"
      "ngrok"
      "typora"
    ];
    # masApps = { OneTab = 1540160809; };
  };

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.bashInteractive;
  };
}
