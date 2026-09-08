{
  pkgs,
  unstablePkgs,
  ...
}: let
  agentVmRun = pkgs.writeShellScriptBin "agent-vm-run" ''
    exec ${pkgs.gnumake}/bin/make --no-print-directory -C /private/etc/nix-darwin agent-vm-run "$@"
  '';
in {
  home.packages =
    (with pkgs; [
      age
      autossh
      bash-completion
      bat
      btop
      cachix
      chafa # terminal graphics protocol - image viewer (Ghostty)
      clang-tools # clang-format, clangd
      cmake
      coreutils-prefixed
      d2
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
      golangci-lint
      graphviz
      guile
      helix
      herdr
      htop
      hugo
      hyperfine
      iftop
      imagemagick
      jujutsu # this is coming from the jj flake overlay
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
      tree
      tree-sitter
      typst
      xz
      yt-dlp
      zstd
    ])
    ++ [
      agentVmRun
      unstablePkgs.neovim
      unstablePkgs.pnpm
      unstablePkgs.uv
    ];
}
