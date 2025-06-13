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

  homebrew.
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
      "slideshower"
    ];
    masApps = {
      Tailscale = 1475387142;
      Notchmeister = 1599169747;
      TestFlight = 899247664;
      WhatsApp = 310633997;
      TypeIt4Me = 6474688391;
      # FIXME: not working, claims already bought by another user
      # "Bike Outliner" = 1588292384;
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYZ+GM6pSUOcbGOhJe6WEeDhjVArUti1Wj3OxIl8IlL paul@oberon"
  ];
}
