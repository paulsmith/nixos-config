{ unstable-pkgs }:

{ pkgs, config, ... }: {
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = with pkgs; [
    autossh
    aws-sam-cli
    awscli
    bashInteractive
    bat
    colima
    curl
    direnv
    difftastic
    dtach
    entr
    ffmpeg
    fx
    fzf
    fd
    gh
    gifsicle
    gifski
    git
    unstable-pkgs.go
    graphviz
    guile
    helix
    htop
    hugo
    hyperfine
    imagemagick
    jq
    # Try macvim after this is merged
    # https://github.com/NixOS/nixpkgs/pull/260094
    # macvim
    magic-wormhole
    mas
    mosh
    neovim
    nixfmt
    unstable-pkgs.ollama
    pipx
    postgresql
    pstree
    pv
    python3
    readline
    ripgrep
    rlwrap
    shellcheck
    sqlite
    unstable-pkgs.sqlc
    swig
    tree
    ttyd
    wget
    xz
    yt-dlp
    zstd
  ];

  programs.git = {
    enable = true;
    userName = "Paul Smith";
    userEmail = "paulsmith@gmail.com";
    aliases = {
      co = "checkout";
      st = "status";
      ci = "commit";
      br = "branch";
    };
    extraConfig = {
      init = { defaultBranch = "main"; };
      push = { autoSetupRemote = true; };
    };
  };

  home.file."${config.xdg.configHome}/sv" = {
    source = ./runit-sv;
    recursive = true;
  };

  home.sessionVariables = {
    SVDIR = "$HOME/service"; # Runit service directory
  };

  programs.bash.initExtra = ''
export PS1="\[\e[1;34m\]\W\[\e[0m\] \[\e[1;33m\]\$\[\e[0m\] "
# Ghostty shell integration
if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi
'';
}
