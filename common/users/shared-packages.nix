{ pkgs, unstable-pkgs }:

{
  # Core development and system packages shared across all users
  core = with pkgs; [
    aws-sam-cli
    awscli
    bashInteractive
    bat
    btop
    cachix
    ccache
    colima
    curl
    difftastic
    direnv
    entr
    fd
    ffmpeg
    fx
    gh
    gifsicle
    gifski
    git
    guile
    helix
    htop
    hugo
    hyperfine
    imagemagick
    iosevka-nerd
    jq
    lua-language-server
    magic-wormhole
    mosh
    nixfmt-rfc-style
    nodejs_22
    pandoc
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
    stylua
    swig
    tree
    wget
    xz
    zstd
  ];

  # Unstable packages shared across users
  unstable = [
    unstable-pkgs.diffedit3
    unstable-pkgs.go
    unstable-pkgs.jujutsu
    unstable-pkgs.neovim
    unstable-pkgs.rustup
    unstable-pkgs.typst
    unstable-pkgs.uv
  ];
}