{ config, pkgs, ... }: {

  users.users.kami = {
    isNormalUser = true;
    description = "kami";
    extraGroups = [ "docker" "podman" ];
    linger = true;
    uid = 2000;
  };

  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  environment.systemPackages = with pkgs; [
    podman-compose
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
    enable = true;
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    description = "Automatically restart containers";
    serviceConfig = {
      Type = "oneshot";
      User = "kami";
      StandardOutput = "file:/home/kami/podman-restart-service.log";
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
      OnCalendar = "16:38";
      Persistent = true;
    };
  };
  
  systemd.services.maintenance = {
    enable = true;
    after = [ "podman.service" ];
    description = "Maintenance";
    serviceConfig = {
      Type = "oneshot";
      User = "kami";
      StandardOutput = "file:/home/kami/maintenance-service.log";
      ExecStartPre = "${pkgs.coreutils}/bin/echo Starting maintenance...";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman ps -q > /home/kami/running'
        ${pkgs.podman}/bin/podman stop --all --timeout 30
      '';
      ExecStartPost = "${pkgs.coreutils}/bin/echo Done running maintenace, rebooting...";
    };
  };
}
