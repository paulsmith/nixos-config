{ unstable-pkgs }:

{ pkgs, config, ... }:
let
  iosevka-nerd = pkgs.callPackage ../../common/users/iosevka-nerd.nix { };
  sharedPackages = import ../../common/users/shared-packages.nix { inherit pkgs unstable-pkgs; };
in
{
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = sharedPackages.core ++ sharedPackages.unstable ++ (with pkgs; [
    # Personal-specific packages
    (lua.withPackages(ps: with ps; [ cjson ]))
    autossh
    cmake
    coreutils-prefixed
    dtach
    fish
    graphviz
    iftop
    mas
    meld
    neofetch
    ninja
    optipng
    rclone
    tmux
    ttyd
    unstable-pkgs.ollama
    unstable-pkgs.sqlc
    unstable-pkgs.tailscale
    vale
    yt-dlp
  ]);

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

  home.file.".claude" = {
    source = ./.claude;
    recursive = true;
  };

  home.sessionVariables = {
    SVDIR = "$HOME/service"; # Runit service directory
    CDPATH = ":$HOME/Dropbox/Projects:$HOME/.config";
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/bin"
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
    "$HOME/.npm-global/bin/"
  ];

  programs.bash.initExtra = builtins.concatStringsSep "\n" [
    (builtins.readFile ../../common/bash/extra.bash)
  ];

  home.file."${config.xdg.configHome}/nvim" = {
    source = ../../common/nvim;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/jj/config.toml" = {
    text = builtins.concatStringsSep "\n" [
        "[user]"
        "name = \"Paul Smith\""
        "email = \"paulsmith@pobox.com\""
        ""
        (builtins.readFile ../../common/jj/config.toml)
    ];
  };

  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };

  home.file.".npmrc" = {
    text = ''
      prefix=/Users/paul/.local
    '';
  };
}
