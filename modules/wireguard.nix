{ config, pkgs, ... }: {

  networking.wg-quick.interfaces = {
  # Host xan01
    wg-xan01 = {
      address = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard/wg-xan01-private.key";
      postUp = [
        "wg addconf wg-xan01 /root/wireguard/wg-xan01-peers.conf"
        "iptables -A FORWARD -i wg-xan01 -j ACCEPT"
        "iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -j MASQUERADE"
      ];
      preDown = [
        "iptables -D FORWARD -i wg-xan01 -j ACCEPT"
        "iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -j MASQUERADE"
      ];
    };

    # Client xan02
    wg-xan02 = {
      address = [ "10.200.0.2/32" ];
      privateKeyFile = "/root/wireguard/wg-xan02-private.key";
      postUp = [
        "wg addconf wg-xan02 /root/wireguard/wg-xan02-peers.conf"
      ];
    }
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg-xan01 wg-xan02" ];
    extraCommands = ''
      iptables -A FORWARD -i wg-xan01 -j ACCEPT
      iptables -A FORWARD -o wg-xan01 -j ACCEPT
    '';
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

}
