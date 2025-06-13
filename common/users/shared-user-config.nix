{ pkgs, config, ... }:
let
  # FIXME this doesn't actually work the way I expected
  dev = pkgs.writeShellScriptBin "dev" ''
    set -eu
    nix flake init -t "github:DeterminateSystems/zero-to-nix#''${1}-dev"
    echo use flake >> .envrc
    direnv allow
  '';
in
{
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  home.shellAliases = {
    ls = "ls --color=auto";
    ll = "ls -l";
    vi = "nvim";
    vim = "nvim";
    view = "nvim -R";
    vimdiff = "nvim -d";
    gs = "git status";
    gd = "git diff";
    gdc = "git diff --cached";
    gau = "git add -u";
    gc = "git commit";
    gco = "git checkout";
  };

  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.dircolors.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.file.".sqliterc".text = ''
    .header on
    .mode column
  '';

  programs.git.extraConfig = {
    "diff \"sqlite3\"" = {
      binary = true;
      textconv = "echo .dump | sqlite3";
    };
    diff = {
      colormoved = "default";
      colormovedws = "allow-indentation-change";
      algorithm = "histogram";
    };
    merge.conflictStyle = "zdiff3";
    transfer.fsckobjects = true;
    fetch = {
      fsckobjects = true;
      prune = true;
      prunetags = true;
    };
    receive.fsckobjects = true;
    core.hooksPath = "${config.xdg.configHome}/git/hooks";
  };

  programs.readline = {
    bindings = {
      "\\C-xP" = "print-last-kbd-macro";
      "\\e\\C-f" = "dump-functions";
      "\\e\\C-o" = "dabbrev-expand";
    };
    variables = {
      colored-stats = true;
      colored-completion-prefix = true;
      keyseq-timeout = 1200;
    };
  };

  home.file."${config.xdg.configHome}/git/ignore".text = ''
    .DS_Store
    .idea
    .envrc
    .direnv/
  '';

  home.file.".gitattributes".text = ''
    *.sqlite diff=sqlite3
  '';

  home.file = {
    ${if pkgs.stdenv.isDarwin
    then "Library/Application Support/com.mitchellh.ghostty/config"
    else "${config.xdg.configHome}/ghostty/config"} = {
      source = ./ghostty;
    };
  };
}
