{ config, pkgs, ... }:{
  
  imports = 
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./../../../modules/default.nix
      ./../../../modules/users/xanedithas.nix
      ./../../../modules/users/tsu01.nix
      ./../../../modules/users/dev.nix
      ./../../../modules/podman.nix
      ./../../../modules/services.nix
    ];

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

  # mDNS broadcast hostname on LAN
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
    openFirewall = true;
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow passwordless sudo as wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
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

  system.stateVersion = "25.05";
}
