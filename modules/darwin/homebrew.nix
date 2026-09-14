{...}: {
  homebrew = {
    enable = true;

    # Never uninstall. Nix guarantees this list is present; anything
    # installed by hand survives untouched.
    onActivation.cleanup = "none";

    # Third-party taps, each the only source for a tool below. 1password-cli
    # and ngrok are deliberately absent: both live in homebrew-cask core, so
    # tapping them added nothing and only triggered Homebrew's tap-trust
    # warning.
    taps = [
      "cirruslabs/cli"
      "llimllib/tap"
      "openclaw/tap"
      "paulsmith/tap"
      "recursiveascent/tap"
      "steipete/tap"
    ];

    brews = [
      "cowsay"
      "opam"
      "qemu"

      # Tap-only tools, fully qualified so the source is unambiguous.
      "cirruslabs/cli/sshpass"
      "openclaw/tap/wacli"
      "paulsmith/tap/jjq"
      "recursiveascent/tap/litefind"
      "recursiveascent/tap/roam"
      "steipete/tap/remindctl"
    ];

    casks = [
      "1password"
      "1password-cli"
      "audacity"
      "avifquicklook"
      "basictex"
      "claude"
      "cleanshot"
      "codex"
      "dangerzone"
      "discord"
      "elmedia-player"
      "gimp"
      "google-chrome"
      "hammerspoon"
      "handy"
      "iina"
      "inkscape"
      "istat-menus"
      "karabiner-elements"
      "kicad"
      "libreoffice"
      "llimllib/tap/mdriver"
      "muesli"
      "musicbrainz-picard"
      "ngrok"
      "obsidian"
      "qlmarkdown"
      "secretive"
      "selfcontrol"
      "slack"
      "slideshower"
      "utm"
    ];

    masApps = {
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
      "Kagi Search" = 1622835804;
      "Keynote" = 361285480;
      "Microsoft Excel" = 462058435;
      "Nitro" = 1591292532;
      "OneTab" = 1540160809;
      "Prime Video" = 545519333;
      "Ruler" = 1563264206;
      "Steam Link" = 1246969117;
      "Swift Playground" = 1496833156;
      "TestFlight" = 899247664;
      "Tomito" = 1526042938;
      "Tot" = 1491071483;
      "WhatsApp" = 310633997;
      "WorldWideWeb" = 1621370168;
      "Xcode" = 497799835;
    };
  };
}
