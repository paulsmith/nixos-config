{ unstable-pkgs }:

{ pkgs, config, ... }:
let
  iosevka-nerd = pkgs.callPackage ../../common/users/iosevka-nerd.nix { };
  sharedPackages = import ../../common/users/shared-packages.nix { inherit pkgs unstable-pkgs; };
in
{
  imports = [ ../../common/users/shared-user-config.nix ];

  home.packages = sharedPackages.core ++ sharedPackages.unstable ++ (with pkgs; [
    # Work-specific packages
    asitop
    datasette
    fzf
    iosevka-nerd
    lua
    openssl_3
    unstable-pkgs.llama-cpp
  ]);

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

  # Bash extras now managed by chezmoi
  # programs.bash.initExtra = builtins.concatStringsSep "\n" [
  #   "export PATH=\"$HOME/Downloads/google-cloud-sdk/bin:$PATH\""
  #   (builtins.readFile ../../common/bash/extra.bash)
  # ];

  # Neovim config now managed by chezmoi
  # home.file."${config.xdg.configHome}/nvim" = {
  #   source = ../../common/nvim;
  #   recursive = true;
  # };

  # JJ config now managed by chezmoi
  # home.file."${config.xdg.configHome}/jj/config.toml" = {
  #   text = builtins.concatStringsSep "\n" [
  #     "[user]"
  #     "name = \"Paul Smith\""
  #     "email = \"paul@adhocteam.us\""
  #     ""
  #     (builtins.readFile ../../common/jj/config.toml)
  #   ];
  # };
}
