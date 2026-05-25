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
    ./../../../modules/dnsmasq.nix
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

          # wg-net: client access network
          iifname "wg-net" ip saddr 10.200.0.12 ip daddr 10.100.0.2 accept
          iifname "wg-net" ip saddr 10.200.0.0/24 ip daddr 10.200.0.0/24 accept
          iifname "wg-net" drop

          # SSH
          tcp dport 1993 accept

          # HTTP/HTTPS
          tcp dport { 80, 443 } accept

          # Port ranges
          tcp dport 25560-25564 accept
          tcp dport 50000-51000 accept
          udp dport 50000-51000 accept

          # mDNS
          udp dport 5353 accept

          # ping
          ip protocol icmp accept
        }

        chain forward {
          type filter hook forward priority filter; policy drop;
          ct state established,related accept

          iifname "wg-net" oifname "wg-net" ip saddr 10.200.0.0/24 ip daddr 10.200.0.0/24 accept

          iifname "wg-net" ip saddr 10.200.0.11 ip daddr 10.100.0.2 accept
          iifname "wg-net" ip saddr 10.200.0.12 ip daddr 10.100.0.2 accept
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100;
          iifname "wg-net" ip saddr 10.200.0.0/24 ip daddr 10.200.0.0/24 masquerade
          iifname "wg-net" ip saddr 10.200.0.11 ip daddr 10.100.0.2 masquerade
          iifname "wg-net" ip saddr 10.200.0.12 ip daddr 10.100.0.2 masquerade
        }
      }
    '';
  };

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.1/24" ];
  networking.wg-quick.interfaces.wg-net.address = [ "10.200.0.1/24" ];

  system.stateVersion = "25.05";
}
