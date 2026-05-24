{ config, pkgs, ... }: {
  
  # Network for clients hub-spoke (behind NAT)
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-net-private.key | wg pubkey > wg-net-public.key
  networking.wg-quick.interfaces.wg-net = {
    listenPort = 50002;
    privateKeyFile = "/root/wireguard/wg-net-private.key";
    postUp = [
      "wg addconf wg-net /root/wireguard/wg-net-peers.conf"
      "iptables -A FORWARD -i wg-net -j ACCEPT"
      "iptables -A FORWARD -o wg-net -j ACCEPT"
      "iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -j MASQUERADE"
    ];
    preDown = [
      "iptables -D FORWARD -i wg-net -j ACCEPT"
      "iptables -D FORWARD -o wg-net -j ACCEPT"
      "iptables -t nat -D POSTROUTING -s 10.200.0.0/24 -j MASQUERADE"
    ];
  };

  networking.firewall = {
    # allowedUDPPorts = [ 50002 ];
    trustedInterfaces = [ "wg-net" ];
  };

}
