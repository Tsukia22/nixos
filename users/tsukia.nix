{ config, lib, ... }:{
  users.users.tsukia = {
    isNormalUser = true;
    description = "Tsukia";
    extraGroups = [ "wheel" ];
    autoSubUidGidRange = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqHCvFmu1uniKAF2TJuefA8eJ3qWX8p9xqjU/ieuL2n TsukiaPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGG4D2L6wPfaLvw2pMG+BAj+4QHVw1qJ4mh+gNmbz00q TsukiaNPC"
    ];
  };
}
