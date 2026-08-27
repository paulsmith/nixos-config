{
  config,
  lib,
  username,
  email,
  homeRepoRoot,
  deliveryMode,
  ...
}: let
  # Deliver a dotfile either as a symlink into the live working repo, so
  # edits take effect without a switch, or as a copy in the Nix store for
  # hosts that have no checkout.
  dotfile = name:
    if deliveryMode == "symlink"
    then config.lib.file.mkOutOfStoreSymlink "${homeRepoRoot}/home/dotfiles/${name}"
    else ./dotfiles/${name};

  gitConfigBody =
    if deliveryMode == "symlink"
    then "${homeRepoRoot}/home/dotfiles/config/git/config-body"
    else "${./dotfiles/config/git/config-body}";
in {
  home = {
    inherit username;
    stateVersion = "26.05";

    sessionVariables = {
      EDITOR = "nvim";
      SVDIR = "$HOME/service";
      FONTCONFIG_FILE = "$HOME/.config/fontconfig/fonts.conf";
    };

    file = {
      ".bashrc".source = dotfile "bashrc";
      ".bash_profile".source = dotfile "bash_profile";
      ".inputrc".source = dotfile "inputrc";
      ".sqliterc".source = dotfile "sqliterc";
      ".gitattributes".source = dotfile "gitattributes";
      ".gitignore_global".source = dotfile "gitignore_global";
      ".tmux.conf".source = dotfile "tmux.conf";
      ".npmrc".source = dotfile "npmrc";

      ".claude/CLAUDE.md".source = dotfile "claude/CLAUDE.md";

      ".config/bat/config".source = dotfile "config/bat/config";
      ".config/fontconfig/fonts.conf".source = dotfile "config/fontconfig/fonts.conf";
      ".config/git/ignore".source = dotfile "config/git/ignore";

      # Identity is generated per host; the body is edited live. git merges
      # the two via [include].
      ".config/git/config".text = ''
        [user]
        	name = Paul Smith
        	email = ${email}

        [core]
        	hooksPath = ${config.home.homeDirectory}/.config/git/hooks

        [include]
        	path = ${gitConfigBody}
      '';

      # jj merges config.toml and every conf.d/*.toml in lexical order.
      ".config/jj/conf.d/00-identity.toml".text = ''
        [user]
        name = "Paul Smith"
        email = "${email}"
      '';
      ".config/jj/conf.d/50-main.toml".source = dotfile "config/jj/50-main.toml";
    };
  };

  # programs.bash would write ~/.bashrc, which is exactly the file delivered
  # above. Left disabled everywhere; bashrc sources hm-session-vars.sh itself.
  programs.home-manager.enable = true;

  xdg.enable = true;
}
