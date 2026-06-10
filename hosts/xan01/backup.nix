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
        
        exit 0;
      '';
    };

    # TODO: Add some kind of btrfs send confirmation the snapshot is fully received.
    
    unitConfig = {
      OnSuccess = "reboot-after-maintenance.service";
    };
  };

}