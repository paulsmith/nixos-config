rec {
  paul = {
    oberon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYZ+GM6pSUOcbGOhJe6WEeDhjVArUti1Wj3OxIl8IlL paul@oberon";
    venus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYzIg4z5qi2uAqLLSM3c4wqcLSHzNwCW0jqQwt/3bvO paul@venus";
    io = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+tz9m2PPg7jriW/l2lOFGwprrf3bMLdeP5C0N8+2zg paul@io";
  };

  vibium = {
    andon = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHrJJ4Kejryy/eWLiBViXiDVVAhv+j9KiXUJthd5ASAZVxJpuMA4f0wSeBpgdMTzML30twkkRfWVaspfv+z+szs= paul@andon";
  };

  personalMachineKeys =
    hostname:
    let
      # Filter out the current host's key
      filterKey =
        if hostname == "oberon" then
          paul.oberon
        else if hostname == "venus" then
          paul.venus
        else if hostname == "io" then
          paul.io
        else
          "";
    in
    builtins.filter (key: key != filterKey) allPersonalKeys;

  allPersonalKeys = [
    paul.oberon
    paul.venus
    paul.io
  ];
}
