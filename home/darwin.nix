{
  config,
  homeRepoRoot,
  deliveryMode,
  ...
}: let
  dotfile = name:
    if deliveryMode == "symlink"
    then config.lib.file.mkOutOfStoreSymlink "${homeRepoRoot}/home/dotfiles/${name}"
    else ./dotfiles/${name};
in {
  imports = [./packages/workstation.nix];

  home = {
    homeDirectory = "/Users/${config.home.username}";

    file = {
      # Symlinked as whole directories so lazy.nvim writes lazy-lock.json
      # straight back into the repo.
      ".config/nvim/init.lua".source = dotfile "config/nvim/init.lua";
      ".config/nvim/lazy-lock.json".source = dotfile "config/nvim/lazy-lock.json";
      ".config/nvim/lua".source = dotfile "config/nvim/lua";

      ".config/karabiner/karabiner.json".source = dotfile "config/karabiner/karabiner.json";

      ".hammerspoon/init.lua".source = dotfile "hammerspoon/init.lua";
      ".hammerspoon/Spoons".source = dotfile "hammerspoon/Spoons";

      "Library/Application Support/com.mitchellh.ghostty/config".source =
        dotfile "ghostty/config";
    };
  };
}
