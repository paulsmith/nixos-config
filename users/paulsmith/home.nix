{ unstable-pkgs }:

{ pkgs, config, ... }:
let iosevka-nerd = pkgs.callPackage ../../common/users/iosevka-nerd.nix { };
in {
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = with pkgs; [
    aws-sam-cli
    awscli
    bashInteractive
    bat
    cachix
    colima
    curl
    datasette
    direnv
    entr
    fd
    ffmpeg
    fx
    fzf
    gh
    gifsicle
    gifski
    git
    unstable-pkgs.go
    guile
    helix
    htop
    hugo
    imagemagick
    iosevka-nerd
    jq
    lua
    lua-language-server
    magic-wormhole
    mosh
    unstable-pkgs.neovim
    nodejs_21
    nixfmt
    openssl_3_1
    postgresql
    pipx
    prettierd
    pstree
    pv
    python3
    readline
    ripgrep
    rlwrap
    unstable-pkgs.rye
    shellcheck
    sqlite
    stylua
    swig
    tree
    wget
    xz
    zstd
  ];

  programs.git = {
    enable = true;
    userName = "Paul Smith";
    userEmail = "paul@adhocteam.us";
    aliases = {
      co = "checkout";
      st = "status";
      ci = "commit";
      br = "branch";
    };
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.starship.enable = true;

  home.sessionPath =
    [ "$HOME/go/bin" "$HOME/bin" "$HOME/.local/bin" "$HOME/.rye/shims" ];

  programs.bash.initExtra = ''
    export PATH="$HOME/Downloads/google-cloud-sdk/bin:$PATH"
    export PS1="\[\e[1;34m\]\W\[\e[0m\] \[\e[1;33m\]\$\[\e[0m\] "
    export MANPATH=$(xcode-select --show-manpaths | tr '\n' ':')
    # Ghostty shell integration
    if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
        builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
    fi
  '';

  home.file."${config.xdg.configHome}/nvim/init.lua" = {
    source = ./init.lua;
  };
}
