{ config, pkgs, ... }:
let
  username = "paul";
  hostname = "venus";
in
{
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.settings.trusted-users = [ "root" username ];
  
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "1password-cli"
      "audacity"
      "avifquicklook"
      "blender"
      "docker"
      "inkscape"
      "karabiner-elements"
      "ngrok"
      "qlmarkdown"
      "rar"
    ];
  };

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.bashInteractive;
  };
}
