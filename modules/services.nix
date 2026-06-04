{ config, pkgs, ... }: 
let
  scripts = import ./scripts.nix { inherit pkgs; };

  sharedScript = ''
      set -eu
      echo $(date +"%Y-%m-%d %H:%M:%S")      
      cd /home/kami
      runuser -l kami -c 'podman ps -q > /home/kami/running'
      runuser -l kami -c 'podman stop --all --timeout 20'
    ''
in {
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
    path = [ pkgs.coreutils pkgs.findutils pkgs.podman pkgs.curl ];
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
        echo "Waiting 5 seconds to send health ping"

        sleep 5
        curl http://10.100.0.1:25558/ping/xfvqwclbw6d3h1pxaaog2w/maintenance-$HOSTNAME
      '';
    };
#    unitConfig = {
#      OnFailure = "curl http://10.100.0.1:25558/ping/xfvqwclbw6d3h1pxaaog2w/maintenance-$HOSTNAME/fail";
#    };
  };
  
  systemd.services.maintenance = {
    description = "Maintenance";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils pkgs.bash pkgs.podman pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      User = "kami";
      StandardOutput = "append:/home/kami/maintenance-service.log";
      StandardError = "append:/home/kami/maintenance-service.log";
      ExecStart = pkgs.writeShellScript "maintenance" ''
        set -eu
        
        echo $(date +"%Y-%m-%d %H:%M:%S")
        echo "Starting maintenance..."

        curl http://10.100.0.1:25558/ping/xfvqwclbw6d3h1pxaaog2w/maintenance-$HOSTNAME/start
        
        bash -c 'podman ps -q > /home/kami/running && podman stop --all --timeout 60'
        
        echo "Done running maintenance."
      '';
    };
#    unitConfig = {
#      OnSuccess = "auto-update.service";
#      OnFailure = "curl http://10.100.0.1:25558/ping/xfvqwclbw6d3h1pxaaog2w/maintenance-$HOSTNAME/fail";
#    };
  };

  systemd.services.auto-update = {
    description = "NixOS Flake auto update";
    wantedBy = lib.mkForce [];
    path = [ pkgs.git pkgs.nix pkgs.nixos-rebuild pkgs.curl ];
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
#    unitConfig = {
#      OnSuccess = "auto-backup.service"; # In the host configuration
#      OnFailure = "curl http://10.100.0.1:25558/ping/xfvqwclbw6d3h1pxaaog2w/maintenance-$HOSTNAME/fail";
#    };
  };
  
  systemd.services.reboot-after-maintenance = {
    description = "Reboot after maintenance";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils pkgs.curl ];
    script = ''
      set -eu
      echo $(date +"%Y-%m-%d %H:%M:%S")
      echo "Rebooting..."
      reboot
    '';
  };
  
  systemd.services.test-fail = {
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    onFailure = [ "notify-fail.service" ];
    script = ''exit 1'';
  };

  systemd.services.notify-fail = {
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    script = scripts.notifyFail { message = "oh no"; target = "10.100.0.1"; };
  };

  systemd.services.test-seq = {
    description = "Test sequence";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    script = ''
      echo "a"
      systemctl start seq-a
      echo "b"
      systemctl start seq-b
      echo "c"
      systemctl start seq-c
      echo "done"
    '';
  };

  systemd.services.seq-a = {
    description = "Test sequence 1";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils ];
    script = ''
      echo "1"
      sleep 4
      echo "1-4"
    '';
  };

  systemd.services.seq-b = {
    description = "Test sequence 2";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils ];
    script = ''
      echo "2"
      sleep 2
      echo "2-2"
    '';
  };

  systemd.services.seq-c = {
    description = "Test sequence 3";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils ];
    script = ''
      echo "3"
      sleep 1
      echo "3-1"
    '';
  };

  systemd.services.manual-shutdown = {
    description = "Manual shutdown";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    path = [ pkgs.util-linux ];
    script = ''
      echo "Manual shutdown!"
      ${sharedScript}
      shutdown now
    '';
  };
  systemd.services.manual-reboot = {
    description = "Manual reboot";
    serviceConfig.Type = "oneshot";
    wantedBy = lib.mkForce [];
    path = [ pkgs.util-linux ];
    script = ''
      echo "Manual reboot!"
      ${sharedScript}
      shutdown -r now
    '';
  };
}