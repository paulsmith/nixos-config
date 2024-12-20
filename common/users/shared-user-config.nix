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

  programs.git.extraConfig."diff \"sqlite3\"".binary = true;
  programs.git.extraConfig."diff \"sqlite3\"".textconv = "echo .dump | sqlite3";
  programs.git.extraConfig.diff.colormoved = "default";
  programs.git.extraConfig.diff.colormovedws = "allow-indentation-change";
  programs.git.extraConfig.merge.conflictStyle = "zdiff3";
  programs.git.extraConfig.diff.algorithm = "histogram";
  programs.git.extraConfig.transfer.fsckobjects = true;
  programs.git.extraConfig.fetch.fsckobjects = true;
  programs.git.extraConfig.receive.fsckobjects = true;
  programs.git.extraConfig.fetch.prune = true;
  programs.git.extraConfig.fetch.prunetags = true;
  programs.git.extraConfig.core.hooksPath = "${config.xdg.configHome}/git/hooks";

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
  '';

  home.file.".gitattributes".text = ''
    *.sqlite diff=sqlite3
  '';

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/bin"
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
  ];

  home.file."${config.xdg.configHome}/ghostty/config" = {
    source = ./ghostty;
  };
}
