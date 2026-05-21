{ config, pkgs, ... }: {

  # Mesh for peer-peer backhaul
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-mesh-private.key | wg pubkey > wg-mesh-public.key
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

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51821 ];
    trustedInterfaces = [ "wg-mesh" ];
    extraCommands = ''
      iptables -A FORWARD -i wg-mesh -j ACCEPT
      iptables -A FORWARD -o wg-mesh -j ACCEPT
    '';
  };

}
