{ config, pkgs, ... }: {

  users.users.docky = {
    isNormalUser = true;
    extraGroups = [ "podman" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB77v/sVFBESpr15nlZe9pv/bHxzGFx3to2z9H0Jn+o5 docky"
    ];
  };
}
