{
  username,
  pkgs,
  unstablePkgs,
  ...
}: let
  agentVmRun = pkgs.writeShellScriptBin "agent-vm-run" ''
    exec ${pkgs.gnumake}/bin/make --no-print-directory -C /private/etc/nix-darwin agent-vm-run "$@"
  '';
in {
  users.users.${username}.packages =
    (with pkgs; [
      age
      autossh
      bash-completion
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
