{ config, lib, pkgs, ... }: 
let
  scripts = import ./scripts.nix { inherit config pkgs; };
in {
  environment.systemPackages = [ scripts.manual-shutdown scripts.manual-reboot ];
  
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

  systemd.services.podman-restart = {
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    description = "Automatically restart containers on boot";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;  # Service stays "active" after running once, to prevent re-running.
      User = "kami";  # Ensure log ownership
      StandardOutput = "append:/home/kami/podman-restart-service.log";
      StandardError = "append:/home/kami/podman-restart-service.log";
      ExecStart = pkgs.writeShellScript "podman-restart" ''
        ${scripts.notifyStart { unit = "podman-restart"; }}
        ${scripts.restartContainersInRunning}
        ${scripts.notifyPing { unit = "podman-restart"; }}
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "podman-restart"; }}";
    };
  };
  
  systemd.services.update-nix = {
    description = "NixOS flake update and rebuild";
    wantedBy = lib.mkForce [];
    path = [ pkgs.git pkgs.nix pkgs.nixos-rebuild pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "append:/root/update-nix-service.log";
      StandardError = "append:/root/update-nix-service.log";
      ExecStart = pkgs.writeShellScript "podman-restart" ''
        set -eu
        ${scripts.dateTime}
        
        echo "Updating flake inputs..."
        nix flake update --flake /root/nixos
        
        echo "Rebuilding for next boot..."
        nixos-rebuild boot --impure --flake /root/nixos#$HOSTNAME
        echo "Update complete. Changes will apply on boot."
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "update-nix"; }}";
    };
  };
  
  systemd.services.maintenance = {
    description = "Maintenance";
    wantedBy = lib.mkForce [];
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "append:/home/kami/maintenance-service.log";
      StandardError = "append:/home/kami/maintenance-service.log";
      ExecStart =  pkgs.writeShellScript "maintenance" ''
        # Start maintenance, send notification
        ${scripts.notifyStart { unit = "maintenance"; }}

        # Write container references to running and stop containers
        ${scripts.writeRunningStopContainers}

        # auto-backup.service host config
        # skip for now, testing... #systemctl start auto-backup.service

        # Update NixOS
        systemctl start update-nix.service

        # OnSuccess notify healthchecks, ExecStopPost is not called here unless it fails
        ${scripts.notifyPing { unit = "maintenance"; }}

        # Reboot
        echo "Rebooting..."
        shutdown -r now
      '';
      ExecStopPost = "${scripts.notifyOnStop { unit = "maintenance"; }}";
    };
  };
}