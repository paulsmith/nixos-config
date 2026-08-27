{pkgs, ...}: {
  home.packages = with pkgs; [
    bashInteractive
    btop
    fastfetch
    htop
    iftop
    pstree
    pv
    python3
    readline
    rlwrap
    tmux
    tree
    xz
    zstd
  ];
}
