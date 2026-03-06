{ config, lib, ... }:{
  users.users.tsukia = {
    isNormalUser = true;
    description = "Tsukia";
    extraGroups = [ "networkmanager" "wheel" ];
    autoSubUidGidRange = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqHCvFmu1uniKAF2TJuefA8eJ3qWX8p9xqjU/ieuL2n TsukiaPC"
    ];
  };
  security.sudo.extraRules = [
    {
      users = [ "tsukia" "xanedithas" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
    {
      users = [ "xan01" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/btrfs receive *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}