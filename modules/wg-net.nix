{ config, pkgs, ... }: {
  
  # Network for clients hub-spoke (behind NAT)
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-net-private.key | wg pubkey > wg-net-public.key
  networking.wg-quick.interfaces.wg-net = {
    listenPort = 50002;
    privateKeyFile = "/root/wireguard/wg-net-private.key";
    postUp = [
      "wg addconf wg-net /root/wireguard/wg-net-peers.conf"
    ];
  };

  networking.firewall = {
    # allowedUDPPorts = [ 50002 ];
    trustedInterfaces = [ "wg-net" ];

    # Allow specific exceptions first (order matters in iptables)
    extraCommands = ''
      iptables -A INPUT -i wg-net -s 10.200.0.12 -d 10.100.0.2 -j ACCEPT

      iptables -A INPUT -i wg-net -s 10.200.0.0/24 -d 10.200.0.1 -j ACCEPT
      iptables -A INPUT -i wg-net -s 10.200.0.0/24 -d 10.200.0.3 -j ACCEPT

      iptables -A FORWARD -i wg-net -j ACCEPT
      iptables -A FORWARD -o wg-net -j ACCEPT
      iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -j MASQUERADE

      # Drop everything else on wg-net
      iptables -A INPUT -i wg-net -j DROP
    '';

    extraStopCommands = ''
      iptables -D INPUT -i wg-net -s 10.200.0.12 -d 10.100.0.2 -j ACCEPT || true

      iptables -D INPUT -i wg-net -s 10.200.0.0/24 -d 10.200.0.1 -j ACCEPT || true
      iptables -D INPUT -i wg-net -s 10.200.0.0/24 -d 10.200.0.3 -j ACCEPT || true

      iptables -D FORWARD -i wg-net -j ACCEPT || true
      iptables -D FORWARD -o wg-net -j ACCEPT || true
      iptables -t nat -D POSTROUTING -s 10.200.0.0/24 -j MASQUERADE || true

      iptables -D INPUT -i wg-net -j DROP || true
    '';
  };

}
