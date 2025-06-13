{
  username,
  hostname,
  nextdnsProfile,
}:
{ config, pkgs, ... }:
let
  baseConfig = import ../../common/hosts/personal-host-base.nix {
    inherit username hostname nextdnsProfile;
  };
in
{
  imports = [ baseConfig ];

  homebrew.onActivation.cleanup = "uninstall";
  homebrew.casks = [
      "1password"
      "1password-cli"
      "anki"
      "audacity"
      "autodesk-fusion"
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
      "google-chrome"
      "hammerspoon"
      "handbrake"
      "iina"
      "imhex"
      "inkscape"
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
      "slideshower"
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
  homebrew.masApps = {
    "Bike Outliner" = 1588292384;
    Tailscale = 1475387142;
    TestFlight = 899247664;
    Tomito = 1526042938;
    TypeIt4Me = 6474688391;
    WhatsApp = 310633997;
  };

}
