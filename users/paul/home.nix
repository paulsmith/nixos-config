{ pkgs, ... }: {
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = with pkgs; [
    autossh
    aws-sam-cli
    awscli
    bash
    bat
    colima
    curl
    datasette
    direnv
    dtach
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
    qemu
    readline
    ripgrep
    rlwrap
    sqlite
    swig
    tree
    wget
    xz
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
