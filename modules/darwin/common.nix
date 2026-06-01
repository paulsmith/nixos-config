{
  pkgs,
  lib,
  username,
  hostname,
  configurationRevision,
  nextdnsProfile,
  ...
}:

{
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [
      "root"
      username
    ];
  };

  system.configurationRevision = configurationRevision;

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    smb.NetBIOSName = hostname;
    screencapture.location = "~/Pictures/screenshots";
  };

  networking.hostName = hostname;
  networking.computerName = hostname;

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  services.nextdns = lib.mkIf (nextdnsProfile != null) {
    enable = true;
    arguments = [
      "-profile"
      nextdnsProfile
      "-cache-size"
      "10MB"
    ];
  };
}
