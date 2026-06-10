{ config, pkgs, ... }:{
  
  # Include the results of the hardware scan.
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/default.nix
    ../../users/xanedithas.nix
    ../../modules/podman.nix
    ../../modules/services.nix
    ../../modules/wg-mesh.nix
    ../../modules/wg-net.nix
    ../../modules/dnsmasq.nix
    ../../modules/host-options.nix
    ./firewall.nix
    ./backup.nix
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
        users = [ "xanedithas" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

#  systemd.timers.maintenance = {
#    wantedBy = [ "timers.target" ];
#    timerConfig = {
#      OnCalendar = "03:30";
#      Persistent = true;
#    };
#  };

  # Networking
  networking.hostName = "xan01";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  # Wireguard config
  networking.wg-quick.interfaces.wg-mesh.address = [ "10.100.0.1/24" ];
  networking.wg-quick.interfaces.wg-net.address = [ "10.200.0.1/24" ];

  # Host options/configs
  # Usage example: ${config.host.domain}
  host.domain = "x.x";
  host.notify-target = "10.100.0.2";
  host.notify-key = "3sl7poangptq1mtladsioa";
  # Snapshots require an existing valid btrfs subvolume (manual one-time operation)
  host.snapshots = {
    volumes = { from = "/home/kami/.local/share/containers/storage/volumes"; to = "/var/snapshots/volumes"; };
  };
#    immich = { from = "/home/kami/stacks/immich/library/library"; to = "/var/snapshots/immich"; };
  # Backups require a pre-existing remote parent snapshot (manual one-time operation)
  host.backups = {
    volumes = { remote = "10.100.0.2"; from = "/tmp/src-configs/var/snapshots/volumes"; to = "/mnt/hdd/$HOSTNAME/backups/volumes"; };
  };
#    immich = { remote = "10.100.0.2"; from = "/tmp/src-configs/var/snapshots/immich"; to = "/mnt/hdd/$HOSTNAME/backups/immich"; };

  system.stateVersion = "25.05";
}
