{ config, pkgs, ... }: {
  # Install Podman
  environment.systemPackages = with pkgs; [
    podman
  ];

  # Enable lingering for your user so rootless services can run
  systemd.user.lingering = [ "docky" ];

  # Optional: podman group is created automatically, add user
  users.users.docky = {
    isNormalUser = true;
    extraGroups = [ "podman" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB77v/sVFBESpr15nlZe9pv/bHxzGFx3to2z9H0Jn+o5 docky"
    ];
  };

  # Optional: Enable rootless Podman service for your user
  # This sets up systemd user socket and service units
  # systemd.user.services.podman-rootless = {
  #   description = "Rootless Podman Service";
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
  #     Restart = "always";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  systemd.user.sockets.podman-rootless = {
    description = "Rootless Podman Socket";
    socketConfig = {
      ListenStream = "/run/user/${config.users.users.docky.uid}/podman/podman.sock";
    };
    wantedBy = [ "sockets.target" ];
  };
}
