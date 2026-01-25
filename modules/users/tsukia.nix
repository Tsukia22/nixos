{ config, lib, ... }:{
  # Tsukia
  users.users.tsukia = {
    isNormalUser = true;
    description = "Tsukia";
    extraGroups = [ "networkmanager" "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqHCvFmu1uniKAF2TJuefA8eJ3qWX8p9xqjU/ieuL2n TsukiaPC"
    ];
  };

  # sudo  
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
  ];
}