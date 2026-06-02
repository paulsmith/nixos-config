{ config, username, ... }:

{
  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = config.local.sshPubKeys.allPersonalKeys ++ [
      config.local.sshPubKeys.vibium.andon
    ];
    hashedPassword = "$y$j9T$4oUIqUeut.17IkmZ5NXin0$qD4MNLXCJuNGPQGbXLPAZTgiquW0wdf/rGrxDAsoMx8";
  };
}
