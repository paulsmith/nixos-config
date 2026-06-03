{
  username,
  pkgs,
  unstablePkgs,
  ...
}:

{
  users.users.${username}.packages =
    (with pkgs; [
      age
      autossh
      bat
      btop
      cachix
      chafa # terminal graphics protocol - image viewer (Ghostty)
      chezmoi
      clang-tools # clang-format, clangd
      cmake
      difftastic
      direnv
      dtach
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
      sqlite
      stylua
      swig
      tmux
      tree
      tree-sitter
      typst
      xz
      yt-dlp
      zstd
    ])
    ++ [
      unstablePkgs.jujutsu
      unstablePkgs.neovim
      unstablePkgs.pnpm
      unstablePkgs.uv
    ];
}
