{
  inputs,
  lib,
  pkgs,
  unstablePkgs,
  username,
  ...
}:

let
  hostRoot = "/Users/paul/microvms/agent-vm";

  hostPkgs = import inputs.nixpkgs {
    system = "aarch64-darwin";
    config.allowUnfree = true;
  };

  optionalUnstable =
    name: lib.optionals (builtins.hasAttr name unstablePkgs) [ unstablePkgs.${name} ];
in
{
  imports = [
    inputs.microvm.nixosModules.microvm
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.kernelParams = [ "quiet" ];

  documentation.enable = false;
  environment.defaultPackages = [ ];

  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network.networks."10-microvm" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "ipv4";
  };

  services.resolved.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/var/lib/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        bits = 4096;
        path = "/var/lib/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  systemd.tmpfiles.rules = [
    "d /home/${username} 0755 ${username} users -"
    "d /home/${username}/.local 0755 ${username} users -"
    "d /home/${username}/.local/state 0755 ${username} users -"
    "d /home/${username}/.local/state/nix 0755 ${username} users -"
    "d /home/${username}/.local/state/nix/profiles 0755 ${username} users -"
    "d /home/${username}/service 0755 ${username} users -"
    "d /var/lib/ssh 0700 root root -"
  ];

  environment.systemPackages =
    (with pkgs; [
      bat
      direnv
      fd
      fzf
      ghostty.terminfo
      neovim
      nix-direnv
      sqlite
      unzip
    ])
    ++ (with unstablePkgs; [
      jujutsu
      uv
    ])
    ++ optionalUnstable "codex";

  nix.settings.trusted-users = [
    "root"
    username
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      dotfiles = inputs.dotfiles;
      inherit unstablePkgs;
    };
    users.${username} = import ../../users/paul/agent-home.nix;
  };

  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 8192;
    vmHostPackages = hostPkgs;
    socket = "agent-vm.sock";
    storeDiskErofsFlags = [
      "-zlz4"
      "-Eztailpacking"
    ];

    preStart = ''
      mkdir -p ${hostRoot}/workspace
      chmod 0777 ${hostRoot}/workspace
    '';

    interfaces = [
      {
        type = "user";
        id = "agent-vm";
        mac = "02:00:00:00:00:01";
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host.port = 2223;
        guest.port = 22;
      }
    ];

    volumes = [
      {
        image = "agent-vm-home.img";
        mountPoint = "/home";
        size = 16384;
      }
      {
        image = "agent-vm-var.img";
        mountPoint = "/var";
        size = 8192;
      }
      {
        image = "agent-vm-rw-store.img";
        mountPoint = "/nix/.rw-store";
        size = 16384;
      }
    ];

    writableStoreOverlay = "/nix/.rw-store";

    shares = [
      {
        proto = "9p";
        tag = "workspace";
        source = "${hostRoot}/workspace";
        mountPoint = "/home/${username}/workspace";
        securityModel = "none";
      }
    ];
  };
}
