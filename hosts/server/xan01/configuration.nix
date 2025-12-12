{ config, pkgs, ... }:{
  
  imports = 
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./../../../modules/default.nix
      ./../../../modules/users/xanedithas.nix
      ./../../../modules/podman.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #fileSystems."/".device = "/dev/disk/by-id/nvme-eui.0000000623090565caf25b038a001068/nixos";

  # Allow passwordless sudo as wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Networking
  networking.hostName = "xan01";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
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
