{ username }:
{ pkgs, ... }: {
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.settings.trusted-users = [ "root" username ];

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = [ "qemu" "runit" "gforth" ];
    casks = [ "1password-cli" "docker" "inkscape" "ngrok" "typora" ];
    # masApps = { OneTab = 1540160809; };
  };

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.bashInteractive;
  };
}
