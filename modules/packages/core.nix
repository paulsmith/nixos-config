{ pkgs, lib, ... }:

{
  environment.systemPackages =
    with pkgs;
    [
      curl
      fd
      git
      jq
      ripgrep
      runit
      tmux
      vim
      wget
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      terminal-notifier
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
    ];
}
