{ config, pkgs, ... }: {

  boot.kernelModules = [ "wireguard" ];

  networking.wg-quick.interfaces.wg0.configFile = "/root/wireguard/wg0.conf";

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg0" ];
    extraCommands = ''
      iptables -A FORWARD -i wg0 -j ACCEPT
      iptables -A FORWARD -o wg0 -j ACCEPT
    '';
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

}
