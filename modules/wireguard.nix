{ config, pkgs, ... }: {

  # Mesh for peer-peer backhaul
  # IP is set at the host config
  networking.wg-quick.interfaces.wg-mesh = {
    listenPort = 51821;
    privateKeyFile = "/root/wireguard/wg-mesh-private.key";
    postUp = [
      "wg addconf wg-mesh /root/wireguard/wg-mesh-peers.conf"
      "iptables -A FORWARD -i wg-mesh -j ACCEPT"
    ];
    preDown = [
      "iptables -D FORWARD -i wg-mesh -j ACCEPT"
    ];
  };
  # Network for clients hub-spoke (behind NAT)
  # IP is set at the host config
  networking.wg-quick.interfaces.wg-net = {
    listenPort = 51822;
    privateKeyFile = "/root/wireguard/wg-net-private.key";
    postUp = [
      "wg addconf wg-net /root/wireguard/wg-net-peers.conf"
      "iptables -A FORWARD -i wg-net -j ACCEPT"
      "iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -j MASQUERADE"
    ];
    preDown = [
      "iptables -D FORWARD -i wg-net -j ACCEPT"
      "iptables -t nat -D POSTROUTING -s 10.200.0.0/24 -j MASQUERADE"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51821 51822 ];
    trustedInterfaces = [ "wg-mesh wg-net" ];
    extraCommands = ''
      iptables -A FORWARD -i wg-mesh -j ACCEPT
      iptables -A FORWARD -o wg-mesh -j ACCEPT
      iptables -A FORWARD -i wg-net -j ACCEPT
      iptables -A FORWARD -o wg-net -j ACCEPT
    '';
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

}
