{ config, lib, pkgs, ... }: 
let
  scripts = import ./scripts.nix { inherit config lib pkgs; };
in {
  environment.systemPackages = [ scripts.manual-shutdown scripts.manual-reboot scripts.manual-stop-containers scripts.check-url scripts.manual-backup ];
  
  systemd.services.test-fail = {
    description = "Test failed service";
    wantedBy = lib.mkForce [];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "test-fail" ''
        exit 1
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "test-fail"; }}";
    };
  };

  systemd.services.on-boot = {
    after = [ "podman.service" "wg-quick-wg-mesh.service" ];
    wantedBy = [ "multi-user.target" ];
    description = "Run once on boot";
    unitConfig.ConditionPathExists = "!/run/on-boot.done";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "on-boot" ''
        set -eux # error check and debug

        # Run only once per boot
        touch /run/on-boot.done

        # Wait up to 2 minutes for wireguard interface to connect to peers
        ${scripts.pingLoop}

        # Done booting
        ${scripts.notifyPing { unit = "boot"; }}

        # Services to start on boot
        systemctl start podman-restart
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "reboot"; }}";
    };
  };

  systemd.services.podman-restart = {
    description = "Restart containers in running";
    wantedBy = lib.mkForce [];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      StandardOutput = "append:/home/kami/podman-restart-service.log";
      StandardError = "append:/home/kami/podman-restart-service.log";
      ExecStart = pkgs.writeShellScript "podman-restart" ''
        ${scripts.notifyStart { unit = "podman-restart"; }}
        ${scripts.restartContainersInRunning}
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "podman-restart"; }}";
    };
  };
  
  systemd.services.update-nix = {
    description = "NixOS flake update and rebuild";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils pkgs.git pkgs.nix pkgs.nixos-rebuild pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "append:/root/update-nix-service.log";
      StandardError = "append:/root/update-nix-service.log";
      ExecStart = pkgs.writeShellScript "podman-restart" ''
        set -eu
        ${scripts.dateTime}
        ${scripts.notifyStart { unit = "update-nix"; }}
        
        echo "Updating flake inputs..."
        nix flake update --flake /root/nixos
        
        echo "Rebuilding for next boot..."
        nixos-rebuild boot --impure --flake /root/nixos#$HOSTNAME
        echo "Update complete. Changes will apply on boot."
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "update-nix"; }}";
    };
  };

  systemd.services.auto-backup = {
    after = [ "auto-update.service" ];
    description = "Auto snapshot and backup according to host options";
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "append:/root/backup-service.log";
      StandardError = "append:/root/backup-service.log";
      ExecStart = pkgs.writeShellScript "auto-backup" ''
        ${scripts.notifyStart { unit = "auto-backup"; }}
        ${scripts.snapshotLoop}
        ${scripts.backupLoop}
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "auto-backup"; }}";
    };
  };
  
  systemd.services.maintenance = {
    description = "Maintenance";
    wantedBy = lib.mkForce [];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "append:/home/kami/maintenance-service.log";
      StandardError = "append:/home/kami/maintenance-service.log";
      ExecStart =  pkgs.writeShellScript "maintenance" ''
        set -eux  # exit on error, print every command before executing

        # Start maintenance, send notification
        ${scripts.notifyStart { unit = "maintenance"; }}

        # Write container references to running and stop containers
        ${scripts.writeRunningStopContainers}

        # auto-backup.service host config
        systemctl start auto-backup.service

        # Update NixOS
        systemctl start update-nix.service

        # Reboot
        ${scripts.notifyStart { unit = "reboot"; }}
        shutdown -r
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "maintenance"; }}";
    };
  };
}