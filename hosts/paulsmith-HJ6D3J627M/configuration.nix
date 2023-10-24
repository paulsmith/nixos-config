{ pkgs, ... }:
let user = "paulsmith";
in {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.nixfmt ];

  nix.package = pkgs.nixUnstable;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" "${user}" ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Enable sudo authentication with Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.defaults.dock.autohide = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    casks = [ "1password-cli" "docker" "inkscape" "ngrok" ];
  };

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    shell = pkgs.bashInteractive;
  };
}
