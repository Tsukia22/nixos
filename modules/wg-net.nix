{ config, pkgs, ... }: {
  
  # Network for clients hub-spoke (behind NAT)
  # IP is set at the host config
  # Generate key: wg genkey | tee wg-net-private.key | wg pubkey > wg-net-public.key
  networking.wg-quick.interfaces.wg-net = {
    configFile = "/root/wireguard/wg-net.conf";
  };

  networking.firewall = {
    # allowedUDPPorts = [ 50002 ];
    trustedInterfaces = [ "wg-net" ];
  };

}
