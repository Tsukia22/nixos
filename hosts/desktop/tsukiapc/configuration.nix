{ config, pkgs, ... }:{

  imports =
    [ # Include the results of the hardware scan.
       /etc/nixos/hardware-configuration.nix # Change this eventually
      
      # TsukiaPC
      ./../../../modules/default.nix
      ./../../../modules/users/tsukia.nix
      ./../../../modules/desktops/kdeplasma.nix
      ./packages.nix
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  # Networking
  networking.hostName = "tsukiapc";
  networking.networkmanager.enable = true;

  # SSH
  networking.firewall.allowedTCPPorts = [  ];
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Audio (PipeWire instead of PulseAudio)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;

  system.stateVersion = "25.05"; 

}
