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
  #networking.firewall.allowedTCPPorts = [  ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  system.stateVersion = "25.05"; 

}
