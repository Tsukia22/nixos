{ config, pkgs, ... }: {
  
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

}