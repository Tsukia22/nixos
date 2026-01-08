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

  systemd.services.podman-rootless-start = {
    description = "Start unless-stopped podman containers at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "kami";
      WorkingDirectory = "/home/kami";
      RemainAfterExit = true;

      Environment = [
        "HOME=/home/kami"
        "XDG_RUNTIME_DIR=/run/user/${toString config.users.users.kami.uid}"
      ];

      ExecStart =
        "${pkgs.podman}/bin/podman start --all --filter restart-policy=unless-stopped";

      ExecStop =
        "${pkgs.podman}/bin/podman stop --all --filter restart-policy=unless-stopped";
    };
  };

}
