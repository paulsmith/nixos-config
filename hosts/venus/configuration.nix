{ username, hostname, nextdnsProfile }:
{ config, pkgs, ... }: {
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.settings.trusted-users = [ "root" username ];

  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = [ "qemu" "runit" ];
    casks = [
      "1password-cli"
      "audacity"
      "avifquicklook"
      "blender"
      "docker"
      "inkscape"
      "karabiner-elements"
      # Local Wordpress development
      "local"
      "ngrok"
      "qlmarkdown"
      "rar"
    ];
    masApps = {
      Tailscale = 1475387142;
      Notchmeister = 1599169747;
      # FIXME: not working, claims already bought by another user
      # "Bike Outliner" = 1588292384;
    };
  };

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.bashInteractive;
  };

  services.nextdns = {
    enable = true;
    arguments = [ "-profile ${nextdnsProfile}" ];
  };
}
