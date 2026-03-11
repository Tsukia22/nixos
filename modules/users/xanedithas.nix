{ pkgs, ... }: {
  users.users.xanedithas = {
    isNormalUser = true;
    description = "Xanedithas";
    extraGroups = [ "networkmanager" "wheel" ];
    autoSubUidGidRange = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY2K6YGEJZ5zh24e2rr+lOk/IXEo7DQ08bHnohGvI/s xanedithas"
    ];
  };
  security.sudo.extraRules = [
    {
      users = [ "xanedithas" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
    {
      users = [ "tsu01" "xan01" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/btrfs receive *";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/btrfs send *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
