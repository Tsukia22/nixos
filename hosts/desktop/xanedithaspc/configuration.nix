{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./../../../modules/default.nix
      ./../../../modules/users/xanedithas.nix
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
  networking.hostName = "xanedithas-pc";
  networking.networkmanager.enable = true;
  services.openssh.enable = true; # enables port 22 automatically

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages
  environment.systemPackages = with pkgs; [];

  system.stateVersion = "25.05";
}
