{ unstable-pkgs }:

{ pkgs, config, ... }:
let
  iosevka-nerd = pkgs.callPackage ../../common/users/iosevka-nerd.nix { };
in
{
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = with pkgs; [
    asitop
    aws-sam-cli
    awscli
    bashInteractive
    bat
    btop
    cachix
    ccache
    colima
    curl
    datasette
    difftastic
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
    guile
    helix
    htop
    hugo
    hyperfine
    imagemagick
    iosevka-nerd
    jq
    lua
    lua-language-server
    magic-wormhole
    mosh
    nixfmt-rfc-style
    nodejs_22
    pandoc
    openssl_3
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
    unstable-pkgs.diffedit3
    unstable-pkgs.go
    unstable-pkgs.jujutsu
    unstable-pkgs.llama-cpp
    unstable-pkgs.neovim
    unstable-pkgs.rustup
    unstable-pkgs.typst
    unstable-pkgs.uv
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
      # url."ssh://git@github.com/".insteadOf = "https://github.com";
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  programs.bash.initExtra = builtins.concatStringsSep "\n" [
    "export PATH=\"$HOME/Downloads/google-cloud-sdk/bin:$PATH\""
    (builtins.readFile ../../common/bash/extra.bash)
  ];

  home.file."${config.xdg.configHome}/nvim" = {
    source = ../../common/nvim;
    recursive = true;
  };

  home.file."Library/Application Support/jj/config.toml" = {
    text = builtins.concatStringsSep "\n" [
        "[user]"
        "name = \"Paul Smith\""
        "email = \"paul@adhocteam.us\""
        ""
        (builtins.readFile ../../common/jj/config.toml)
    ];
  };
}
