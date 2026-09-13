{
  config,
  username,
  ...
}: {
  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = config.local.sshPubKeys.allPersonalKeys;
    hashedPassword = "$y$j9T$4oUIqUeut.17IkmZ5NXin0$qD4MNLXCJuNGPQGbXLPAZTgiquW0wdf/rGrxDAsoMx8";
  };
}
