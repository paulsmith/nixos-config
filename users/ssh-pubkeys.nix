{ lib, ... }:

let
  inherit (lib) types;
in
{
  options.local.sshPubKeys = {
    paul = lib.mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    vibium = lib.mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    allPersonalKeys = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config.local.sshPubKeys = rec {
    paul = {
      oberon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYZ+GM6pSUOcbGOhJe6WEeDhjVArUti1Wj3OxIl8IlL paul@oberon";
      venus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYzIg4z5qi2uAqLLSM3c4wqcLSHzNwCW0jqQwt/3bvO paul@venus";
      io = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+tz9m2PPg7jriW/l2lOFGwprrf3bMLdeP5C0N8+2zg paul@io";
    };

    vibium = {
      andon = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHrJJ4Kejryy/eWLiBViXiDVVAhv+j9KiXUJthd5ASAZVxJpuMA4f0wSeBpgdMTzML30twkkRfWVaspfv+z+szs= paul@andon";
    };

    allPersonalKeys = lib.attrValues paul;
  };
}
