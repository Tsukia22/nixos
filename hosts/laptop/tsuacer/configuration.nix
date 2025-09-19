{ config, pkgs, ... }:{

  imports =
    [
      ./hardware-configuration.nix
      ./../../../modules/default.nix
      ./../../../modules/users/tsukia.nix

      # tsuacer
      ./../../../modules/podman.nix
    ];

  # Networking
  networking.hostName = "tsuacer";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  networking.firewall.allowedTCPPorts = [ 443 80 ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 25560; to = 25564; } # local use
    { from = 50000; to = 51000; } # external use
  ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  system.stateVersion = "25.05"; 

}
