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
  };

}
