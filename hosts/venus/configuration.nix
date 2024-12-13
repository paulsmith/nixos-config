{ username, hostname, nextdnsProfile }:
{ config, pkgs, ... }: {
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.settings.trusted-users = [ "root" username ];

  networking.hostName = hostname;
  networking.computerName = hostname;

  system.defaults = {
      dock.autohide = true;
      dock.mru-spaces = false;
      smb.NetBIOSName = hostname;
      screencapture.location = "~/Pictures/screenshots";
  };

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
      # "blender" was taking too long to upgrade
      "docker"
      "inkscape"
      "karabiner-elements"
      "lulu"
      "musicbrainz-picard"
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
    enable = false;
    arguments = [ "-profile" "${nextdnsProfile}" "-cache-size" "10MB" ];
  };
}
