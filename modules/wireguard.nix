{ config, pkgs, ... }: {

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard/private.key";
    postUp = [
      "wg addconf wg0 /root/wireguard/wg0-peers.conf"
      "iptables -A FORWARD -i wg0 -j ACCEPT"
      "iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -j MASQUERADE"
    ];
    preDown = [
      "iptables -D FORWARD -i wg0 -j ACCEPT"
      "iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -j MASQUERADE"
    ];
  };

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
