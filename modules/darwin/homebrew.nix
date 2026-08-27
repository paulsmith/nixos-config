{
  lib,
  isVibium,
  ...
}: {
  homebrew = {
    enable = true;

    # Never uninstall. Nix guarantees this list is present; anything
    # installed by hand survives untouched.
    onActivation.cleanup = "none";

    taps = [
      "1password/tap"
      "ngrok/ngrok"
    ];

    brews = [
      "cowsay"
      "opam"
      "qemu"
    ];

    casks =
      [
        "1password"
        "1password-cli"
        "basictex"
        "claude"
        "cleanshot"
        "codex"
        "dangerzone"
        "google-chrome"
        "hammerspoon"
        "handy"
        "istat-menus"
        "karabiner-elements"
        "ngrok"
        "obsidian"
        "qlmarkdown"
        "secretive"
        "slack"
        "utm"
      ]
      ++ lib.optionals (!isVibium) [
        "audacity"
        "avifquicklook"
        "discord"
        "elmedia-player"
        "gimp"
        "iina"
        "inkscape"
        "kicad"
        "libreoffice"
        "musicbrainz-picard"
        "rar"
        "selfcontrol"
        "slideshower"
      ];

    masApps =
      {
        "Kagi Search" = 1622835804;
        "Keynote" = 409183694;
        "Microsoft Excel" = 462058435;
        "Numbers" = 409203825;
        "Pages" = 409201541;
        "Swift Playground" = 1496833156;
        "TestFlight" = 899247664;
        "Tomito" = 1526042938;
        "Xcode" = 497799835;
      }
      // lib.optionalAttrs (!isVibium) {
        "Bike" = 1588292384;
        "Blackmagic Disk Speed Test" = 425264550;
        "Brother P-touch Editor" = 1453365242;
        "File Viewer" = 495987613;
        "Free Ruler" = 1483172210;
        "GarageBand" = 682658836;
        "Hand Mirror" = 1502839586;
        "Hyperspace" = 6739505345;
        "iMovie" = 408981434;
        "Ivory" = 6444602274;
        "Mimeo Photos" = 1282504627;
        "Nitro" = 1591292532;
        "OneTab" = 1540160809;
        "Prime Video" = 545519333;
        "Ruler" = 1563264206;
        "Steam Link" = 1246969117;
        "StopTheMadness" = 1376402589;
        "Tot" = 1491071483;
        "WhatsApp" = 310633997;
        "WorldWideWeb" = 1621370168;
      };
  };
}
