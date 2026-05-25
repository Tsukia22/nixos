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
  networking.firewall.enable = false;

  # Packages
  environment.systemPackages = with pkgs; [
    git     # Git version control
    unzip   # Extract .zip archives
    curl    # Download files from URLs / HTTP requests
    wget    # Download files from URLs (CLI)
    parted  # Disk partitioning
    btop    # Monitoring
  ];

  # SSH hardening
  services.openssh = {
    enable = true;
    ports = [ 1993 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Fail2ban
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "2h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 3 4 6 8 12";
      maxtime = "24h";
      overalljails = true;
    };
  };
  
  # Cleanup
  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 30d";
  };

  # mDNS broadcast hostname on LAN
  # firewall handled by host config
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    allowInterfaces = [ "enp3s0" ];
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Wireguard setting
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  nix.extraOptions = ''
  experimental-features = nix-command flakes
'';
}
