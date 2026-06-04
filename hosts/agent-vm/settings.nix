{ username }:

let
  name = "agent-vm";
  homeDirectory = "/home/${username}";
  hostRoot = "/Users/paul/microvms/${name}";
  writableStoreOverlay = "/nix/.rw-store";
in
{
  inherit
    homeDirectory
    hostRoot
    name
    writableStoreOverlay
    ;

  resources = {
    vcpu = 4;
    mem = 8192;
  };

  ssh = {
    hostPort = 2223;
    guestPort = 22;
    hostKeyDirectory = "/var/lib/ssh";
  };

  network = {
    interfaceId = name;
    mac = "02:00:00:00:00:01";
  };

  workspace = {
    tag = "workspace";
    hostPath = "${hostRoot}/workspace";
    guestPath = "${homeDirectory}/workspace";
  };

  volumes = [
    {
      name = "home";
      mountPoint = "/home";
      size = 16384;
    }
    {
      name = "var";
      mountPoint = "/var";
      size = 8192;
    }
    {
      name = "rw-store";
      mountPoint = writableStoreOverlay;
      size = 16384;
    }
  ];
}
