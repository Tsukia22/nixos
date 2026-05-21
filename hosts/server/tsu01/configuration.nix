{ config, pkgs, ... }:{

  #./hardware-configuration.nix
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./../../../modules/default.nix
    ./../../../modules/users/tsukia.nix
    ./../../../modules/users/xanedithas.nix
    ./../../../modules/users/xan01.nix
    ./../../../modules/podman.nix
    ./../../../modules/services.nix
    ./../../../modules/wg-mesh.nix
    ./../../../modules/wg-net.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  systemd.timers.maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:30";
      Persistent = true;
    };
  };

  systemd.services.auto-backup = {
    after = [ "auto-update.service" ];
    description = "NixOS Flake auto backup";
    path = [ pkgs.nix ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/root/nixos";
      StandardOutput = "append:/root/backup-service.log";
      StandardError = "append:/root/backup-service.log";
      ExecStart = pkgs.writeShellScript "nixos-backup" ''
        set -eu
        
        echo "Not yet implemented auto-backup on $(hostname)"
      '';
    };
    
    unitConfig = {
      OnSuccess = "reboot-after-maintenance.service";
    };
  };

  # Networking
  networking.hostName = "tsu01";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  networking.firewall.allowedTCPPorts = [ 443 80 ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 25560; to = 25564; } # local use
    { from = 50000; to = 51000; } # external use
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 50000; to = 51000; } # external use
  ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.3/24" ];
  networking.wg-quick.interfaces.wg-net.address = [ "10.200.0.3/24" ];

  system.stateVersion = "25.05";
}
