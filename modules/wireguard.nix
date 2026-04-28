{ config, pkgs, ... }: {

  # Enable kernel module. NixOS handles this automatically, being explicit.
  boot.kernelModules = [ "wireguard" ];

  networking.wireguard.interfaces.wg0 = {

    # The IP address of THIS server on the Wireguard network.
    # /24 means the subnet is 10.100.0.0 – 10.100.0.255
    # The server claims .1, clients will get .2, .3, etc.
    ips = [ "10.100.0.1/24" ];

    # Standard Wireguard port. UDP only, Wireguard doesn't use TCP.
    listenPort = 51820;

    # Point to the private key file, NOT the key itself.
    privateKeyFile = "/root/wireguard/private.key";

    peers = [
      # One block per client. You'll add more later.
      {
        publicKey = "Iriz0gzjLs13DGL+CDPu9/NJ7tSK6f2+BCVDQ7QYFio=";

        # This client is only allowed to use the IP 10.100.0.2
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];

    # iptables rules that run after the interface comes up.
    # FORWARD: allows packets to pass through (wg → container network).
    # MASQUERADE: rewrites the source IP so containers see the server
    # as the origin, not the client's WG IP. Needed for return traffic.
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -j MASQUERADE
    '';

    # Mirror of postSetup — clean up rules when the interface goes down.
    # Without this, restarting leaves duplicate rules.
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -j MASQUERADE
    '';

  };

  # Open the WG port publicly.
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg0" ];

    # This is required for the FORWARD iptables rule above to work.
    # NixOS's firewall drops forwarded packets by default.
    allowedUDPPortRanges = [];
    extraCommands = ''
      iptables -A FORWARD -i wg0 -j ACCEPT
      iptables -A FORWARD -o wg0 -j ACCEPT
    '';
  };

  # Allow the kernel to forward packets between interfaces.
  # Without this, the server receives tunnel packets but
  # won't route them onward to containers.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

}
