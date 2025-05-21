{
  username,
  hostname,
  nextdnsProfile,
}:
{ config, pkgs, ... }:
{
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.package = pkgs.nixVersions.nix_2_28;

  nix.settings.trusted-users = [
    "root"
    username
  ];

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
    brews = [
      "qemu"
      "runit"
    ];
    casks = [
      "1password-cli"
      "audacity"
      "avifquicklook"
      "basictex"
      "dangerzone"
      "docker"
      "elmedia-player"
      "ghostty"
      "hammerspoon"
      "iina"
      "inkscape"
      "karabiner-elements"
      "libreoffice"
      "musicbrainz-picard"
      "ngrok"
      "qlmarkdown"
      "rar"
      "selfcontrol"
    ];
    masApps = {
      Tailscale = 1475387142;
      Notchmeister = 1599169747;
      TestFlight = 899247664;
      WhatsApp = 310633997;
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
    arguments = [
      "-profile"
      "${nextdnsProfile}"
      "-cache-size"
      "10MB"
    ];
  };
}
