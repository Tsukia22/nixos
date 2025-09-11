{ config, pkgs, ... }: {

  users.users.kami = {
    isNormalUser = true;
    description = "kami";
    extraGroups = [ "wheel" "docker" "podman" ];
    linger = true;
    uid = 2000;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY2K6YGEJZ5zh24e2rr+lOk/IXEo7DQ08bHnohGvI/s xanedithas"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqHCvFmu1uniKAF2TJuefA8eJ3qWX8p9xqjU/ieuL2n TsukiaPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB77v/sVFBESpr15nlZe9pv/bHxzGFx3to2z9H0Jn+o5 kami"
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