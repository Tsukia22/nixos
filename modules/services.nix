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
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;  # Service stays "active" after running once
      User = "kami";
      StandardOutput = "append:/home/kami/podman-restart-service.log";
      StandardError = "append:/home/kami/podman-restart-service.log";
      ExecStartPre = "${pkgs.coreutils}/bin/echo Restarting containers...";
      ExecStart = ''
        ${pkgs.findutils}/bin/xargs -r -n 1 ${pkgs.podman}/bin/podman restart < /home/kami/running
      '';
      ExecStartPost = "${pkgs.coreutils}/bin/echo Done restarting containers.";
    };
  };
  
  systemd.services.maintenance = {
    description = "Maintenance";
    serviceConfig = {
      Type = "oneshot";
      User = "kami";
      StandardOutput = "append:/home/kami/maintenance-service.log";
      StandardError = "append:/home/kami/maintenance-service.log";
      ExecStartPre = "${pkgs.coreutils}/bin/echo Starting maintenance...";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman ps -q > /home/kami/running && ${pkgs.podman}/bin/podman stop --all --timeout 60'";
      ExecStartPost = "${pkgs.coreutils}/bin/echo Done running maintenance.";
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
        
        echo "Updating flake inputs..."
        ${pkgs.nix}/bin/nix flake update --flake /root/nixos
        
        echo "Rebuilding for next boot..."
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --impure --flake /root/nixos#$(hostname)
        
        echo "Update complete. Changes will apply on next reboot."
      '';
    };
    
    unitConfig = {
      OnSuccess = "auto-backup.service"; # In the host configuration
    };
  };
  
  systemd.services.reboot-after-maintenance = {
    description = "Reboot after maintenance";
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/echo Rebooting...";
      ExecStart = "${pkgs.bash}/bin/bash -c 'reboot'";
    };
  };
  
  systemd.services.manual-shutdown = {
    description = "Manual shutdown for unplanned maintenance";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "manual-shutdown" ''
        set -eu
        
        echo "Manual shutdown!"
        
        cd /home/kami
        ${pkgs.util-linux}/bin/su -l kami -c 'podman ps -q > /home/kami/running'
        ${pkgs.util-linux}/bin/su -l kami -c 'podman stop --all --timeout 60'

        shutdown
      '';
    };
  };

}