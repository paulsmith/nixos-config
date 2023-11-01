{ pkgs, ... }:
let user = "paulsmith";
in {
  imports = [ ../../common/hosts/shared-host-config.nix ];

  nix.settings.trusted-users = [ "root" "${user}" ];

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    casks = [ "1password-cli" "docker" "inkscape" "ngrok" ];
    # masApps = { OneTab = 1540160809; };
  };

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    shell = pkgs.bashInteractive;
  };
}
