{
  config,
  lib,
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

  # Homebrew 7.0 refuses to tap an untrusted third-party tap, so every tap in
  # modules/darwin/homebrew.nix must be trusted or the Homebrew phase of a
  # switch fails on a machine that has not tapped it before.
  #
  # This is written rather than symlinked: Homebrew updates its own trust store
  # during installs and refuses one whose directory it does not own, which a
  # Nix store symlink is not.
  home.activation.homebrewTrustStore = lib.hm.dag.entryAfter ["writeBoundary"] ''
        trust_dir="$HOME/.homebrew"
        run mkdir -p "$trust_dir"
        run cat > "$trust_dir/trust.json" <<'TRUST'
    ${builtins.toJSON {
      trustedtaps = [
        "cirruslabs/cli"
        "llimllib/tap"
        "openclaw/tap"
        "paulsmith/tap"
        "recursiveascent/tap"
        "steipete/tap"
      ];
    }}
    TRUST
        run chmod 600 "$trust_dir/trust.json"
  '';
}
