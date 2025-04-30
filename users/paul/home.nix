{ unstable-pkgs }:

{ pkgs, config, ... }:
let
  iosevka-nerd = pkgs.callPackage ../../common/users/iosevka-nerd.nix { };
in
{
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = with pkgs; [
    autossh
    aws-sam-cli
    awscli
    bashInteractive
    bat
    btop
    cachix
    ccache
    cmake
    colima
    coreutils-prefixed
    curl
    difftastic
    direnv
    dtach
    entr
    fd
    ffmpeg
    fish
    fx
    gh
    gifsicle
    gifski
    git
    graphviz
    guile
    helix
    htop
    hugo
    hyperfine
    iftop
    imagemagick
    iosevka-nerd
    jq
    lua-language-server
    (lua.withPackages(ps: with ps; [ cjson ]))
    magic-wormhole
    mas
    meld
    mosh
    neofetch
    ninja
    nixfmt-rfc-style
    nodejs_22
    optipng
    pandoc
    pipx
    postgresql
    pstree
    pv
    python3
    rclone
    readline
    ripgrep
    rlwrap
    shellcheck
    sqlite
    stylua
    swig
    tree
    ttyd
    unstable-pkgs.diffedit3
    unstable-pkgs.go
    unstable-pkgs.jujutsu
    unstable-pkgs.neovim
    unstable-pkgs.ollama
    unstable-pkgs.rustup
    unstable-pkgs.sqlc
    unstable-pkgs.tailscale
    unstable-pkgs.typst
    unstable-pkgs.utm
    vale
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
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };

  programs.fzf.enable = true;

  home.file."${config.xdg.configHome}/sv" = {
    source = ./runit-sv;
    recursive = true;
  };

  home.sessionVariables = {
    SVDIR = "$HOME/service"; # Runit service directory
    CDPATH = ":$HOME/Dropbox/Projects";
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/bin"
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
    "$HOME/.npm-global/bin/"
  ];

  programs.bash.initExtra = builtins.concatStringsSep "\n" [
    (builtins.readFile ./bash/extra.bash)
  ];

  home.file."${config.xdg.configHome}/nvim" = {
    source = ../../common/nvim;
    recursive = true;
  };
}
