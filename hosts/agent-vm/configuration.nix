{
  inputs,
  lib,
  pkgs,
  unstablePkgs,
  username,
  ...
}:

let
  settings = import ./settings.nix { inherit username; };

  hostPkgs = import inputs.nixpkgs {
    system = "aarch64-darwin";
    config.allowUnfree = true;
  };

  optionalUnstable = name: lib.optional (builtins.hasAttr name unstablePkgs) unstablePkgs.${name};

  tmpdirRule =
    {
      path,
      mode ? "0755",
      user ? username,
      group ? "users",
    }:
    "d ${path} ${mode} ${user} ${group} -";

  userStateDirs = [
    settings.homeDirectory
    "${settings.homeDirectory}/.local"
    "${settings.homeDirectory}/.local/state"
    "${settings.homeDirectory}/.local/state/nix"
    "${settings.homeDirectory}/.local/state/nix/profiles"
    "${settings.homeDirectory}/service"
  ];

  microvmVolume = volume: {
    image = "${settings.name}-${volume.name}.img";
    inherit (volume) mountPoint size;
  };
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
        path = "${settings.ssh.hostKeyDirectory}/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        bits = 4096;
        path = "${settings.ssh.hostKeyDirectory}/ssh_host_rsa_key";
        type = "rsa";
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  systemd.tmpfiles.rules = map (path: tmpdirRule { inherit path; }) userStateDirs ++ [
    (tmpdirRule {
      path = settings.ssh.hostKeyDirectory;
      mode = "0700";
      user = "root";
      group = "root";
    })
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
      inherit unstablePkgs username;
    };
    users.${username} = import ../../users/paul/agent-home.nix;
  };

  microvm = {
    hypervisor = "qemu";
    inherit (settings.resources) mem vcpu;
    vmHostPackages = hostPkgs;
    socket = "${settings.name}.sock";
    storeDiskErofsFlags = [
      "-zlz4"
      "-Eztailpacking"
    ];

    preStart = ''
      mkdir -p ${settings.workspace.hostPath}
      chmod 0777 ${settings.workspace.hostPath}
    '';

    interfaces = [
      {
        type = "user";
        id = settings.network.interfaceId;
        inherit (settings.network) mac;
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host.port = settings.ssh.hostPort;
        guest.port = settings.ssh.guestPort;
      }
    ];

    volumes = map microvmVolume settings.volumes;

    writableStoreOverlay = settings.writableStoreOverlay;

    shares = [
      {
        proto = "9p";
        tag = settings.workspace.tag;
        source = settings.workspace.hostPath;
        mountPoint = settings.workspace.guestPath;
        securityModel = "none";
      }
    ];
  };
}
