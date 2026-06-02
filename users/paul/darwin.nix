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
    age
    autossh
    bat
    btop
    cachix
    ccache
    chafa # terminal graphics protocol - image viewer (Ghostty)
    chezmoi
    clang-tools # clang-format, clangd
    cmake
    colima
    coreutils-prefixed
    diffedit3
    difftastic
    direnv
    dtach
    e2fsprogs
    entr
    fastfetch
    ffmpeg
    fx
    fzf
    gh
    gifsicle
    gifski
    go-bin.latestStable # this is coming from go-overlay
    graphviz
    guile
    helix
    htop
    hugo
    hyperfine
    iftop
    imagemagick
    lua-language-server
    magic-wormhole
    mas
    mitmproxy
    mosh
    ninja
    nix-direnv
    nodejs_24
    optipng
    pandoc
    postgresql
    pstree
    pv
    python3
    rclone
    readline
    restic
    rlwrap
    rrdtool
    rustup
    shellcheck
    sqlite
    stylua
    swig
    tmux
    tree
    tree-sitter
    typst
    unstablePkgs.jujutsu
    unstablePkgs.neovim
    unstablePkgs.pnpm
    unstablePkgs.uv
    xz
    yt-dlp
    zstd
  ];

  fonts.packages = with pkgs; [ nerd-fonts.iosevka-term ];

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "check";
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
  };

  users.users.paul = {
    home = "/Users/paul";
    shell = pkgs.bashInteractive;
    description = "Paul Smith";
    openssh.authorizedKeys.keys = lib.optionals (!isVibium) sshPubKeys.allPersonalKeys;
  };

  system.primaryUser = "paul";
}
