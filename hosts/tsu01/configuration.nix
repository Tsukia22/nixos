{ config, pkgs, ... }:{

  #./hardware-configuration.nix
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/default.nix
    ../../users/tsukia.nix
    ../../users/xanedithas.nix
    ../../modules/podman.nix
    ../../modules/services.nix
    ../../modules/wg-mesh.nix
    ../../modules/wg-net.nix
    ../../modules/dnsmasq.nix
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
        users = [ "tsukia" "xanedithas" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  systemd.timers.maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:30";
      Persistent = true;
    };
  };

  # Networking
  networking.hostName = "tsu01";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.3/24" ];
  networking.wg-quick.interfaces.wg-net.address = [ "10.200.0.3/24" ];

  system.stateVersion = "25.05";
}
