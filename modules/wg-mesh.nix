{ config, pkgs, ... }: {

  # Mesh for peer-peer backhaul
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-mesh-private.key | wg pubkey > wg-mesh-public.key
  networking.wg-quick.interfaces.wg-mesh = {
    listenPort = 50001;
    privateKeyFile = "/root/wireguard/wg-mesh-private.key";
    postUp = [
      "wg addconf wg-mesh /root/wireguard/wg-mesh-peers.conf"
    ];
  };

}
