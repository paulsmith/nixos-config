{
  pkgs,
  ...
}:
{
  nix-rosetta-builder = {
    onDemand = true;
    # Make the VM SSH user key group/other-readable so other tailnet hosts
    # (e.g. io) can copy it and authenticate to this builder directly.
    permitNonRootSshAccess = true;
  };

  # Expose the rosetta-builder VM SSH to the tailnet. Lima only forwards it to
  # 127.0.0.1:31122 on this host, so bridge the Tailscale IP to that local port,
  # letting other tailnet hosts use this Mac Studio as a remote Linux builder.
  launchd.daemons.rosetta-builder-tailnet.serviceConfig = {
    ProgramArguments = [
      "${pkgs.socat}/bin/socat"
      "TCP-LISTEN:31122,bind=100.78.221.42,fork,reuseaddr"
      "TCP:127.0.0.1:31122"
    ];
    KeepAlive = true;
    RunAtLoad = true;
  };
}
