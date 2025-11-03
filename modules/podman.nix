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
};
