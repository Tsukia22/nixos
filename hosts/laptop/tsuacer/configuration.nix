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
  networking.firewall.allowedTCPPorts = [ 5001 ];
  networking.firewall.allowedTCPPortRanges = [{ from = 25550; to = 25600; }];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  system.stateVersion = "25.05"; 

}
