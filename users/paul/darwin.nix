{
  pkgs,
  unstablePkgs,
  config,
  ...
}: let
  lib = pkgs.lib;
in {
  imports = [
    ../ssh-pubkeys.nix
    {inherit lib;}
  ];

  fonts.packages = with pkgs; [nerd-fonts.iosevka-term];

  users.users.paul = {
    home = "/Users/paul";
    shell = pkgs.bashInteractive;
    description = "Paul Smith";
    openssh.authorizedKeys.keys = config.local.sshPubKeys.allPersonalKeys;
  };

  system.primaryUser = "paul";
}
