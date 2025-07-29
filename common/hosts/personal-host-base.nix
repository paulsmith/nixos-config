{
  username,
  hostname,
  nextdnsProfile,
}:
{ config, pkgs, ... }:
let
  sshKeys = import ../users/ssh-keys.nix;
in
{
  imports = [ ./shared-host-config.nix ];

  nix.package = pkgs.nixVersions.nix_2_28;

  nix.settings = {
    trusted-users = [
      "root"
      username
    ];

    extra-platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    extra-sandbox-paths = [
      "/System/Library/Frameworks"
      "/System/Library/PrivateFrameworks"
    ];

    builders-use-substitutes = true;
  };

  nix.distributedBuilds = true;

  nix.buildMachines = [
    {
      hostName = "linux-builder"; # Host (or SSH alias)
      sshUser = "builder";
      sshKey = "/etc/nix/builder_ed25519";
      system = "aarch64-linux"; # Target platform
      maxJobs = 4;
    }
  ];

  networking.hostName = hostname;
  networking.computerName = hostname;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    smb.NetBIOSName = hostname;
    screencapture.location = "~/Pictures/screenshots";
  };

  nixpkgs.hostPlatform = "aarch64-darwin";


  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.bashInteractive;
    description = "Paul Smith";
    openssh.authorizedKeys.keys = sshKeys.personalMachineKeys hostname;
  };

  services.nextdns = {
    enable = false;
    arguments = [
      "-profile"
      "${nextdnsProfile}"
      "-cache-size"
      "10MB"
    ];
  };

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 14d";
  };
}
