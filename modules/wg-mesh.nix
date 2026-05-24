{ config, pkgs, ... }: {

  # Mesh for peer-peer backhaul
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-mesh-private.key | wg pubkey > wg-mesh-public.key
  networking.wg-quick.interfaces.wg-mesh = {
    configFile = "/root/wireguard/wg-mesh.conf";
  };

  networking.firewall = {
    # allowedUDPPorts = [ 50001 ];
    trustedInterfaces = [ "wg-mesh" ];
  };

}
