{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
      # TsukiaPC
      ./modules/default.nix
      ./modules/users/Tsukia.nix
      ./modules/desktops/audio.nix
      ./modules/desktops/kdeplasma.nix

      # Services
      ./modules/security.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # networking
  networking.hostName = "tsukiapc";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [  ];
  services.openssh enable = true;
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Audio (PipeWire i.p.v. PulseAudio)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages
  environment.systemPackages = with pkgs; [
    steam
    discord
  ];


  system.stateVersion = "25.05"; # Did you read the comment?

}
