{ config, pkgs, ... }:{

  #./hardware-configuration.nix
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/default.nix
    ../../users/tsukia.nix
    ../../users/xanedithas.nix
    ../../modules/podman.nix
    ../../modules/services.nix
    ../../modules/wg-mesh.nix
    ../../modules/wg-net.nix
    ../../modules/dnsmasq.nix
    ../../modules/host-options.nix
    ./firewall.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Allow passwordless sudo as wheel
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraRules = [
      {
        users = [ "tsukia" "xanedithas" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  systemd.timers.maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
    };
  };

  # Networking
  networking.hostName = "tsu01";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.3/24" ];
  networking.wg-quick.interfaces.wg-net.address = [ "10.200.0.3/24" ];

  # Host options/configs
  
  # Usage example: ${config.host.domain}
  host.domain = "t.t";
  host.notify-target = "10.100.0.2";
  host.notify-key = "3sl7poangptq1mtladsioa";

  # Snapshots require an existing valid btrfs subvolume (manual one-time operation)
  host.snapshots = {
    volumes = { from = "/home/kami/.local/share/containers/storage/volumes"; to = "/var/snapshots/volumes"; };
  };

  # Backups require an existing remote parent snapshot (manual one-time operation)
  host.backups = {
    volumes = { remote = "10.100.0.2"; from = "/var/snapshots/volumes"; to = "/mnt/hdd/$HOSTNAME/backups/volumes"; };
  };

  system.stateVersion = "25.05";
}
