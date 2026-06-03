{
  username,
  pkgs,
  ...
}:

{
  users.users.${username}.packages = with pkgs; [
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
