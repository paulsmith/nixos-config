{ pkgs, unstable-pkgs }:

{
  # Core development and system packages shared across all users
  core = with pkgs; [
    age
    # aws-sam-cli
    # awscli
    bashInteractive
    bat
    btop
    cachix
    ccache
    chafa # terminal graphics protocol - image viewer (Ghostty)
    chezmoi
    clang-tools # clang-format, clangd
    curl
    difftastic
    direnv
    e2fsprogs
    entr
    fd
    ffmpeg
    fx
    fzf
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
    jq
    lua-language-server
    magic-wormhole
    mitmproxy
    mosh
    nix-direnv
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
    tree-sitter
    wget
    xz
    zstd
  ];

  # Unstable packages shared across users
  unstable = [
    unstable-pkgs.colima
    unstable-pkgs.diffedit3
    unstable-pkgs.go
    unstable-pkgs.jujutsu
    unstable-pkgs.neovim
    unstable-pkgs.pnpm
    unstable-pkgs.rustup
    unstable-pkgs.typst
    unstable-pkgs.uv
  ];
}
