{
  pkgs,
  unstablePkgs,
  isVibium,
  config,
  ...
}:

let
  lib = pkgs.lib;
  sshPubKeys = import ../ssh-pubkeys.nix;
in
{
  users.users.paul.packages = with pkgs; [
    colima
    coreutils-prefixed
    e2fsprogs
    mas
  ];

  fonts.packages = with pkgs; [ nerd-fonts.iosevka-term ];

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
    };
    taps = [ ];
    brews = [ "cowsay" ];
    casks = [
      "1password"
      "claude"
      "cleanshot"
      "codex"
      "discord"
      "ghostty"
      "google-chrome"
      "hammerspoon"
      "handy"
      "istat-menus"
      "obsidian"
      "secretive"
      "slack"
      "utm"
    ];
    masApps = {
      "Tomito" = 1526042938;
      "GarageBand" = 682658836;
      "iMovie" = 408981434;
      "Keynote" = 361285480;
      "Numbers" = 361304891;
      "Pages" = 361309726;
    };
  };

  users.users.paul = {
    home = "/Users/paul";
    shell = pkgs.bashInteractive;
    description = "Paul Smith";
    openssh.authorizedKeys.keys = lib.optionals (!isVibium) sshPubKeys.allPersonalKeys;
  };

  system.primaryUser = "paul";
}
