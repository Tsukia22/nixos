{ config, lib, ... }:{
  users.users.tsukia = {
    isNormalUser = true;
    description = "Tsukia";
    extraGroups = [ "wheel" ];
    autoSubUidGidRange = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHab09pAQHamtsVpcDkfEmZ56aZ2FloBILvxf3y0kWbA Tsukia"
    ];
  };
}
