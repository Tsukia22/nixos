{ config, pkgs, ... }: {

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

        btrfs subvolume snapshot -r /home/kami/.local/share/containers/storage/volumes /var/snapshots/volumes/volumes-$(date +%Y%m%d)

        PREV=$(ls /var/snapshots/volumes/ | sort | tail -2 | head -1)
        CURR=$(ls /var/snapshots/volumes/ | sort | tail -1)

        echo "$PREV -> $CURR"

        btrfs send -p /var/snapshots/volumes/$PREV /var/snapshots/volumes/$CURR | ssh xan01@10.100.0.2 -p 1993 "sudo btrfs receive /mnt/hdd/xan01/backups/volumes/"

        echo "Backup volumes complete."
        echo "Backing up immich..."

        btrfs subvolume snapshot -r /home/kami/stacks/immich/library/library /var/snapshots/immich/immich-$(date +%Y%m%d)

        PREV=$(ls /var/snapshots/immich/ | sort | tail -2 | head -1)
        CURR=$(ls /var/snapshots/immich/ | sort | tail -1)

        echo "$PREV -> $CURR"

        btrfs send -p /var/snapshots/immich/$PREV /var/snapshots/immich/$CURR | ssh xan01@10.100.0.2 -p 1993 "sudo btrfs receive /mnt/hdd/xan01/backups/immich/"

        echo "Backup immich complete."
      '';
    };
    
    unitConfig = {
      OnSuccess = "reboot-after-maintenance.service";
    };
  };

}