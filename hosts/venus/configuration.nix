{ pkgs, ... }:
let
  user = "paul";
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
  ];

  environment.shells = with pkgs; [ bashInteractive ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes repl-flake";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  
  # Enable sudo authentication with Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;

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
    casks = [
      "1password-cli"
	  "avifquicklook"
	  "blender"
      "docker"
      "inkscape"
      "ngrok"
	  "qlmarkdown"
	  "rar"
    ];
  };

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    shell = pkgs.bashInteractive;
  };
}
