{ pkgs, ... }: {
  users.users.tsu01 = {
    isNormalUser = true;
    description = "tsu01";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKetWsXfzov6aQUYQR/AX4iIQGxLnugQ9BhzSqVAqBPi tsu01 on xan01"
    ];
  };
}
