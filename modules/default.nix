{ config, pkgs, lib, ... }: {
  
  # Timezone
  time.timeZone = "Europe/Amsterdam";

  # Language
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT    = "nl_NL.UTF-8";
    LC_MONETARY       = "nl_NL.UTF-8";
    LC_NAME           = "nl_NL.UTF-8";
    LC_NUMERIC        = "nl_NL.UTF-8";
    LC_PAPER          = "nl_NL.UTF-8";
    LC_TELEPHONE      = "nl_NL.UTF-8";
    LC_TIME           = "nl_NL.UTF-8";
  };
  
  # Firewall
  networking.firewall.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    git     # Git version control
    unzip   # Extract .zip archives
    curl    # Download files from URLs / HTTP requests
    wget    # Download files from URLs (CLI)
    parted  # Disk partitioning
  ];

  # SSH hardening
  services.openssh = {
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Fail2ban
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "12h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
  };

  nix.extraOptions = ''
  experimental-features = nix-command flakes
'';
}
