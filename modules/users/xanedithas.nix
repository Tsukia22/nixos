{ ... }: {
  users.users.xanedithas = {
    isNormalUser = true;
    description = "Xanedithas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "InitialP";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY2K6YGEJZ5zh24e2rr+lOk/IXEo7DQ08bHnohGvI/s xanedithas"
    ];
  };
}
