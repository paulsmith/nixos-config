{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./packages/vm.nix];

  home = {
    homeDirectory = "/home/${config.home.username}";

    # Only init.lua is managed; lazy.nvim owns the plugin tree and needs it
    # writable, which a store path is not.
    file.".config/nvim/init.lua".source = ./dotfiles/config/nvim/init.lua;

    activation.removeLegacyNvimPluginSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for path in "$HOME/.config/nvim/lazy-lock.json" "$HOME/.config/nvim/lua"; do
        if [ -L "$path" ]; then
          target="$(${pkgs.coreutils}/bin/readlink "$path")"
          case "$target" in
            /nix/store/*) ${pkgs.coreutils}/bin/rm "$path" ;;
          esac
        fi
      done
    '';
  };

  fonts.fontconfig.enable = true;
}
