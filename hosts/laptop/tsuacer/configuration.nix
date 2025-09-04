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
  networking.firewall.allowedTCPPorts = [ 8384 ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  services.syncthing = {
    enable = true;
    user = "tsukia";
    openDefaultPorts = true;
    settings.gui = {
      user = "user";
      password = "password";
      address = "0.0.0.0:8384";
    };
  };

  system.stateVersion = "25.05"; 

}
