{ ... }: {
  users.users.docky = {
    isNormalUser = true;
    description = "docky";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY2K6YGEJZ5zh24e2rr+lOk/IXEo7DQ08bHnohGvI/s xanedithas"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqHCvFmu1uniKAF2TJuefA8eJ3qWX8p9xqjU/ieuL2n TsukiaPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB77v/sVFBESpr15nlZe9pv/bHxzGFx3to2z9H0Jn+o5 docky"
    ];
  };
}
