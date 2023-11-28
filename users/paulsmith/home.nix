{ pkgs, ... }: {
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = with pkgs; [
    aws-sam-cli
    awscli
    bashInteractive
    bat
    colima
    curl
    datasette
    direnv
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
    imagemagick
    jq
    magic-wormhole
    mosh
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
}
