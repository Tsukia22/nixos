{ config, pkgs, ... }:{
  
  imports = 
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./../../../modules/default.nix
      ./../../../modules/users/xanedithas.nix
      #./../../../modules/podman.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow passwordless sudo as wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Networking
  networking.hostName = "xan01";
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  # Packages
  #environment.systemPackages = with pkgs; [ k3s ];

  system.stateVersion = "25.05";
}
