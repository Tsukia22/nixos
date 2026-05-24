{ config, pkgs, ... }: {

  # Mesh for peer-peer backhaul
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-mesh-private.key | wg pubkey > wg-mesh-public.key
  networking.wg-quick.interfaces.wg-mesh = {
    listenPort = 50001;
    privateKeyFile = "/root/wireguard/wg-mesh-private.key";
    postUp = [
      "wg addconf wg-mesh /root/wireguard/wg-mesh-peers.conf"
      "iptables -A FORWARD -i wg-mesh -j ACCEPT"
      "iptables -A FORWARD -o wg-mesh -j ACCEPT"
      "iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -j MASQUERADE"
    ];
    preDown = [
      "iptables -D FORWARD -i wg-mesh -j ACCEPT"
      "iptables -D FORWARD -o wg-mesh -j ACCEPT"
      "iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -j MASQUERADE"
    ];
  };

  networking.firewall = {
    # allowedUDPPorts = [ 50001 ];
    trustedInterfaces = [ "wg-mesh" ];
  };

}
