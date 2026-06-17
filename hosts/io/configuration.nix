{ ... }:
{
  # io runs no local Linux builder. It offloads aarch64-linux / x86_64-linux
  # builds to oberon's nix-rosetta-builder VM, reached directly over the tailnet:
  # oberon bridges its Tailscale IP to the VM's SSH port (see hosts/oberon). The
  # VM's user key lives at /etc/nix/rosetta-builder_user_ed25519 (copied out of
  # band; not in the Nix store), and its host key is pinned below.
  nix-rosetta-builder.enable = false;

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "rosetta-builder-oberon";
      sshUser = "builder";
      sshKey = "/etc/nix/rosetta-builder_user_ed25519";
      protocol = "ssh-ng";
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      maxJobs = 8;
      speedFactor = 1;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
  nix.settings.builders-use-substitutes = true;

  environment.etc."ssh/ssh_config.d/110-rosetta-builder-oberon.conf".text = ''
    Host rosetta-builder-oberon
      Hostname 100.78.221.42
      Port 31122
      User builder
      HostKeyAlias rosetta-builder-key
      IdentityFile /etc/nix/rosetta-builder_user_ed25519
      IdentitiesOnly yes
      GlobalKnownHostsFile /etc/ssh/ssh_known_hosts.d/rosetta-builder
      StrictHostKeyChecking yes
  '';
  environment.etc."ssh/ssh_known_hosts.d/rosetta-builder".text =
    "rosetta-builder-key ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUB8y3JrNS2tQ8lwSCYc1gjnGzFM4HuH0x5RjPgiMRi root@rosetta-builder\n";
}
