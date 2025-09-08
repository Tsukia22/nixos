{ pkgs, ... }: {

  # Enable KDE Plasma 6
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    fwupd  # Firmware update manager
  ];

  # Enable fwupd daemon
  services.fwupd.enable = true;

}