{ config, pkgs, ... }:{
  
  # Include the results of the hardware scan.
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/default.nix
    ../../users/xanedithas.nix
    ../../users/xan01.nix
    ../../users/tsu01.nix
    ../../modules/podman.nix
    ../../modules/services.nix
    ../../modules/wg-mesh.nix
    ./firewall.nix
    ./backup.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Allow passwordless sudo as wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraRules = [
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
  };

  systemd.timers.maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
  };

  # Networking
  networking.hostName = "xan02";

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.2/24" ];

  system.stateVersion = "25.11";
}
