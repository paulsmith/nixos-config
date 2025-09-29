{ unstable-pkgs }:

{ pkgs, config, ... }:
let
  iosevka-nerd = pkgs.callPackage ../../common/users/iosevka-nerd.nix { };
  sharedPackages = import ../../common/users/shared-packages.nix { inherit pkgs unstable-pkgs; };
in
{
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = sharedPackages.core ++ sharedPackages.unstable ++ (with pkgs; [
    # Personal-specific packages
    (lua.withPackages (ps: with ps; [ cjson ]))
    autossh
    chez
    cmake
    coreutils-prefixed
    dtach
    fish
    graphviz
    iftop
    iosevka-nerd
    mas
    meld
    neofetch
    ninja
    optipng
    rclone
    rrdtool
    tmux
    ttyd
    unstable-pkgs.ollama
    unstable-pkgs.sqlc
    unstable-pkgs.tailscale
    vale
    yt-dlp
  ]);

  home.file."${config.xdg.configHome}/sv" = {
    source = ./runit-sv;
    recursive = true;
  };
}
