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

  systemd.user.services.podman-restart = {
    description = "Podman start containers with restart policy unless-stopped on boot";
    documentation = [ "man:podman-start(1)" ];

    wants = [ "network-online.target" ];
    after  = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "LOGGING=--log-level=info";

      ExecStart =
        "${pkgs.podman}/bin/podman $LOGGING start --all --filter restart-policy=unless-stopped";

      ExecStop =
        "${pkgs.podman}/bin/podman $LOGGING stop --all --filter restart-policy=unless-stopped";
    };

    install = {
      WantedBy = [ "default.target" ];
    };
  };

  /*
    # To test without homemanager automation
    systemctl --user daemon-reexec
    systemctl --user enable podman-restart.service
    systemctl --user start podman-restart.service
  */
}
