{ pkgs, ... }: {
  users.users.dev = {
    isNormalUser = true;
    description = "dev";
    extraGroups = [ "docker" "podman" ];
    linger = true;
    uid = 2001;
    autoSubUidGidRange = false;
    subUidRanges = [
      { startUid = 165536; count = 65536; }
    ];
    subGidRanges = [
      { startGid = 165536; count = 65536; }
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
  
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
