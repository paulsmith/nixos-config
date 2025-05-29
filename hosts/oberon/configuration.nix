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
      cleanup = "uninstall";
      upgrade = true;
    };
    brews = [
      "qemu"
      "runit"
    ];
    casks = [
      "1password"
      "1password-cli"
      "anki"
      "audacity"
      "avifquicklook"
      "bambu-studio"
      "bartender"
      "blender"
      "chatgpt"
      "claude"
      "dangerzone"
      "darktable"
      "discord"
      "docker"
      "dropbox"
      "elmedia-player"
      "fujitsu-scansnap-home"
      "ghostty"
      "hammerspoon"
      "handbrake"
      "iina"
      "imhex"
      "inkscape"
      "karabiner-elements"
      "libreoffice"
      "little-snitch"
      "macwhisper"
      "moom"
      "musicbrainz-picard"
      "netnewswire"
      "ngrok"
      "obs"
      "obsidian"
      "openscad"
      "parallels"
      "phoenix-slides"
      "qgis"
      "qlmarkdown"
      "rar"
      "sanesidebuttons"
      "selfcontrol"
      "signal"
      "sonos"
      "soundsource"
      "steam"
      "tic80"
      # "topaz-video-ai"
      "utm"
      "vlc"
      "zed"
      "zoom"
    ];
    masApps = {
      "Bike Outliner" = 1588292384;
      Tailscale = 1475387142;
      TestFlight = 899247664;
      Tomito = 1526042938;
      TypeIt4Me = 6474688391;
      WhatsApp = 310633997;
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
