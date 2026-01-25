{ pkgs, ... }: {
  users.users.testuser = {
    isNormalUser = true;
    description = "Testuser";
  };
}
