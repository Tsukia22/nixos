{ config, pkgs, ... }:{
  
  # Include the results of the hardware scan.
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./../../../modules/default.nix
    ./../../../modules/users/xanedithas.nix
    ./../../../modules/users/tsu01.nix
    ./../../../modules/users/dev.nix
    ./../../../modules/podman.nix
    ./../../../modules/services.nix
    ./../../../modules/wg-mesh.nix
    ./../../../modules/wg-net.nix
  ];
  
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Allow passwordless sudo as wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  systemd.timers.maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
    };
  };

  systemd.services.auto-backup = {
    after = [ "auto-update.service" ];
    description = "NixOS Flake auto backup";
    path = [ pkgs.btrfs-progs pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/root/nixos";
      StandardOutput = "append:/root/backup-service.log";
      StandardError = "append:/root/backup-service.log";
      ExecStart = pkgs.writeShellScript "nixos-backup" ''
        set -eu
        
        echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Backing up volumes..."

        btrfs subvolume snapshot -r /home/kami/.local/share/containers/storage/volumes /var/snapshots/volumes-$(date +%Y%m%d)

        PREV=$(ls /var/snapshots/ | sort | tail -2 | head -1)
        CURR=$(ls /var/snapshots/ | sort | tail -1)

        echo "$PREV -> $CURR"

        btrfs send -p /var/snapshots/$PREV /var/snapshots/$CURR | ssh xan01@192.168.0.54 -p 1993 "sudo btrfs receive ~/backups/"

        echo "Backup complete."
      '';
    };
    
    unitConfig = {
      OnSuccess = "reboot-after-maintenance.service";
    };
  };

  # Networking
  networking.hostName = "xan01";
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
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.1/24" ];
  networking.wg-quick.interfaces.wg-net.address = [ "10.200.0.1/24" ];

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      interface = "wg-net";
      bind-interfaces = true;
      no-resolv = true;
      no-poll = true;
      expand-hosts = true;
      address = [
        "/xan.xan/10.200.0.1"
        "/xan.lan/10.200.0.1"
        "/xan.wg/10.200.0.1"
        "/xan.vpn/10.200.0.1"
        "/x.x/10.200.0.1"
        "/xan.internal/10.200.0.1"
        "/tsu.tsu/10.200.0.3"
        "/tsu.lan/10.200.0.3"
        "/tsu.wg/10.200.0.2"
        "/tsu.vpn/10.200.0.3"
        "/t.t/10.200.0.3"
        "/tsu.internal/10.200.0.3"
      ];
    };
  };

  system.stateVersion = "25.05";
}
