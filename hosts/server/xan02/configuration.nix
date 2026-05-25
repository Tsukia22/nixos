{ config, pkgs, ... }:{
  
  # Include the results of the hardware scan.
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./../../../modules/default.nix
    ./../../../modules/users/xanedithas.nix
    ./../../../modules/users/xan01.nix
    ./../../../modules/podman.nix
    ./../../../modules/services.nix
    ./../../../modules/wg-mesh.nix
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
      OnCalendar = "04:00";
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

  # Firewall
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain input {
          type filter hook input priority filter; policy drop;

          # Allow established/related connections
          ct state established,related accept
          # Allow loopback
          iifname "lo" accept

          # wg-mesh: trusted backbone between servers
          iifname "wg-mesh" ip daddr 10.100.0.0/24 accept
          iifname "wg-mesh" drop

          # SSH
          tcp dport 1993 accept

          # Port ranges
          tcp dport 25560-25564 accept

          # mDNS
          udp dport 5353 accept

          # ping
          ip protocol icmp accept
        }
      }
    '';
  };

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.2/24" ];

  system.stateVersion = "25.11";
}
