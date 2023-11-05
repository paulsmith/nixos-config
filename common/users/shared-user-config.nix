{ pkgs, ... }:
let
  # FIXME this doesn't actually work the way I expected
  dev = pkgs.writeShellScriptBin "dev" ''
    set -eu
    nix flake init -t "github:DeterminateSystems/zero-to-nix#''${1}-dev"
    echo use flake >> .envrc
    direnv allow
  '';
in {
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
    };
    initExtra = ''
export PS1="\[\e[1;34m\]\W\[\e[0m\] \[\e[1;33m\]\$\[\e[0m\] "
'';
  };

  programs.dircolors.enable = true;
  programs.direnv.enable = true;
  programs.starship.enable = false;

  home.file.".sqliterc".text = ''
    .header on
    .mode column
  '';

  programs.git.extraConfig."diff \"sqlite3\"".binary = true;
  programs.git.extraConfig."diff \"sqlite3\"".textconv = "echo .dump | sqlite3";

  home.file.".gitattributes".text = ''
    *.sqlite diff=sqlite3
  '';

  imports = [ ../vim/default.nix ];
}
