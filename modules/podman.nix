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
      Type = "idle";
      User = "kami";
      StandardOutput = "file:/home/kami/podman-restart-service.log";
      ExecStartPre = "/bin/echo Restarting containers...";
      ExecStart = ''
        xargs -r -n 1 podman restart < /home/kami/running
      '';
      ExecStartPost = "/bin/echo Done restarting containers.";
    };
  };
}
