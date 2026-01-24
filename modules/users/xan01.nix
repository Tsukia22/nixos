{ pkgs, ... }: {
  users.users.xan01 = {
    isNormalUser = true;
    description = "xan01";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEynzKPSkWn5p3rL0jvMa++wnr2PdN1t8r5CsEAmrMvF xan01 on tsu01"
    ];
  };
}
