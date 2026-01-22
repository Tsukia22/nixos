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

  # Automatically start containers should-start-on-boot
  systemd.services.podman-autostart = {
    enable = true;
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    description = "Automatically start containers should-start-on-boot";
    serviceConfig = {
      Type = "idle";
      User = "kami";
      ExecStartPre = ''${pkgs.coreutils}/bin/sleep 1'';
      ExecStart = ''/run/current-system/sw/bin/podman restart --all --filter restart-policy=always'';
    };
  };
}
