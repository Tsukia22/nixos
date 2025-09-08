{ config, pkgs, ... }:{

  imports =
    [ # Include the results of the hardware scan.
       /etc/nixos/hardware-configuration.nix # Change this eventually
      
      # tsuacer
      ./../../../modules/default.nix
      ./../../../modules/users/tsukia.nix
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    
  };
  # Networking
  networking.hostName = "tsuacer";
  networking.firewall.allowedTCPPorts = [  ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  system.stateVersion = "25.05"; 

}
