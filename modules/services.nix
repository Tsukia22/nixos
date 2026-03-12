{ config, pkgs, ... }: {

  # # Automatically start containers should-start-on-boot
  # systemd.services.podman-autostart = {
  #   enable = true;
  #   after = [ "podman.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   description = "Automatically start containers should-start-on-boot";
  #   serviceConfig = {
  #     Type = "idle";
  #     User = "kami";
  #     ExecStartPre = ''${pkgs.coreutils}/bin/sleep 1'';
  #     ExecStart = ''/run/current-system/sw/bin/podman restart --all --filter should-start-on-boot=true'';
  #   };
  # };

  systemd.services.podman-restart = {
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    description = "Automatically restart containers";
    path = [ pkgs.coreutils pkgs.findutils pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;  # Service stays "active" after running once
      User = "kami";
      StandardOutput = "append:/home/kami/podman-restart-service.log";
      StandardError = "append:/home/kami/podman-restart-service.log";
      ExecStart = pkgs.writeShellScript "podman-restart" ''
        set -eu
        
        echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Starting containers..."
        
        xargs -r -n 1 podman restart < /home/kami/running
        
        echo "Done starting containers."
      '';
    };
  };
  
  systemd.services.maintenance = {
    description = "Maintenance";
    path = [ pkgs.coreutils pkgs.bash pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      User = "kami";
      StandardOutput = "append:/home/kami/maintenance-service.log";
      StandardError = "append:/home/kami/maintenance-service.log";
      ExecStart = pkgs.writeShellScript "maintenance" ''
        set -eu
        
        echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Starting maintenance..."
        
        bash -c 'podman ps -q > /home/kami/running && podman stop --all --timeout 60'
        
        echo "Done running maintenance."
      '';
    };
    unitConfig = {
      OnSuccess = "auto-update.service";
    };
  };

  systemd.services.auto-update = {
    after = [ "maintenance.service" ];
    description = "NixOS Flake auto update";
    path = [ pkgs.git pkgs.nix pkgs.nixos-rebuild ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/root/nixos";
      StandardOutput = "append:/root/update-service.log";
      StandardError = "append:/root/update-service.log";
      ExecStart = pkgs.writeShellScript "nixos-update" ''
        set -eu
        
        echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Updating flake inputs..."
        nix flake update --flake /root/nixos
        
        echo "Rebuilding for next boot..."
        nixos-rebuild boot --impure --flake /root/nixos#$(hostname)
        
        echo "Update complete. Changes will apply on boot."
      '';
    };
    
    unitConfig = {
      OnSuccess = "auto-backup.service"; # In the host configuration
    };
  };
  
  systemd.services.reboot-after-maintenance = {
    description = "Reboot after maintenance";
    path = [ pkgs.coreutils pkgs.bash ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "echo Rebooting...";
      ExecStart = "bash -c 'reboot'";
    };
  };
  
  systemd.services.manual-shutdown = {
    description = "Manual shutdown for unplanned maintenance";
    path = [ pkgs.util-linux ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "manual-shutdown" ''
        set -eu

        echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Manual shutdown!"
        
        cd /home/kami
        runuser -l kami -c 'podman ps -q > /home/kami/running'
        runuser -l kami -c 'podman stop --all --timeout 20'

        shutdown now
      '';
    };
  };

}