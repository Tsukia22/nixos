{ config, pkgs, ... }:{

  imports =
    [ ./hardware-configuration.nix
      ./../../../modules/default.nix
      ./../../../modules/users/tsukia.nix

      # tsuacer
      ./../../../modules/podmansecond.nix
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    
  };
  # Networking
  networking.hostName = "tsuacer";
  networking.firewall.allowedTCPPorts = [ 5001 ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  system.stateVersion = "25.05"; 

}
