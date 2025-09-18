{ pkgs, ... }: {
 
  # User packages
  users.users.tsukia.packages = with pkgs; [
  discord
];

  # Gaming Modules
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  
  # Hardware & Drivers
  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true; 
  
  # Browser
  programs.firefox.enable = true;

  programs.git = {
    enable = true;
    # Use Homemanager to put settings per user!
    # userName = "Tsukia";
    # userEmail = "67642144+Tsukia22@users.noreply.github.com";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}