{ pkgs, config, ... }:
{
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.05";

  programs.home-manager.enable = false;
}
