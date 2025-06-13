{
  # Centralized SSH public key management for Paul's machines
  paul = {
    # SSH keys for personal machines
    oberon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYZ+GM6pSUOcbGOhJe6WEeDhjVArUti1Wj3OxIl8IlL paul@oberon";
    venus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYzIg4z5qi2uAqLLSM3c4wqcLSHzNwCW0jqQwt/3bvO paul@venus";
    io = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+tz9m2PPg7jriW/l2lOFGwprrf3bMLdeP5C0N8+2zg paul@io";
  };

  # Helper functions to generate key sets for different access patterns
  personalMachineKeys = hostname: 
    let 
      allKeys = [
        paul.oberon
        paul.venus
        paul.io
      ];
      # Filter out the current host's key
      filterKey = if hostname == "oberon" then paul.oberon
                  else if hostname == "venus" then paul.venus  
                  else if hostname == "io" then paul.io
                  else "";
    in
    builtins.filter (key: key != filterKey) allKeys;

  # All personal keys (useful for cross-machine access)
  allPersonalKeys = [
    paul.oberon
    paul.venus
    paul.io
  ];
}