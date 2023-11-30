{ unstable-pkgs }:

{ pkgs, ... }: {
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
    dtach
    ffmpeg
    fx
    fzf
    fd
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
	# Try macvim after this is merged
	# https://github.com/NixOS/nixpkgs/pull/260094
    # macvim
    magic-wormhole
    mas
    mosh
    neovim
    nixfmt
    postgresql
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
}
