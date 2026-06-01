{ pkgs, lib, ... }:

{
  environment.systemPackages =
    with pkgs;
    [
      curl
      jq
      ripgrep
      runit
      tmux
      wget
      git
      vim
      fd
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      terminal-notifier
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
    ];
}
