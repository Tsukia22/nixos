{ config, pkgs, ... }:{

  imports =
    [ # Include the results of the hardware scan.
       /etc/nixos/hardware-configuration.nix # Change this eventually
      
      # tsu01
      ./../../../modules/default.nix
      ./../../../modules/users/tsukia.nix
    ];

  # Networking
  networking.hostName = "tsu01";
  networking.firewall.allowedTCPPorts = [ 443 80 ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 25560; to = 25564; } # local use
    { from = 50000; to = 51000; } # external use
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 50000; to = 51000; } # external use
  ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  system.stateVersion = "25.05"; 

}
