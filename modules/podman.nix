{ config, pkgs, ... }: {

  users.users.kami = {
    isNormalUser = true;
    description = "kami";
    extraGroups = [ "docker" "podman" ];
    linger = true;
    uid = 2000;
    subUidRanges = [
      { startUid = 100000; count = 65536; }
    ];
    subGidRanges = [
      { startGid = 100000; count = 65536; }
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  environment.systemPackages = with pkgs; [
    podman-compose
    borgbackup
  ];

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

  systemd.timers.maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
    };
  };
  
  systemd.services.maintenance = {
    after = [ "podman.service" ];
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
      OnSuccess = "reboot-after-maintenance.service";
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
}
