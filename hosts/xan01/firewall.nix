{ config, pkgs, ... }: {

  # Firewall
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain input {
          type filter hook input priority filter; policy drop;

          ct state established,related accept
          ct state invalid drop
          iifname "lo" accept

          # Local network + wg-net: only these ports
          ip saddr { 192.168.0.0/24, 10.200.0.0/24 } tcp dport {
            1993,
            80, 443,
            3921,           # FTP
            12000-12099,    # FTP passive
            25550-25564,
            50000-51000
          } accept

          ip saddr { 192.168.0.0/24, 10.200.0.0/24 } udp dport {
            5353,  # mDNS
            50000-51000
          } accept

          ip saddr { 192.168.0.0/24, 10.200.0.0/24 } ip protocol icmp accept  # ping

          # wg-mesh: only other mesh members
          iifname "wg-mesh" ip saddr 10.100.0.0/24 accept
        }

        chain forward {
          type filter hook forward priority filter; policy drop;

          ct state established,related accept
          ct state invalid drop

          # wg-net clients can reach each other
          iifname "wg-net" oifname "wg-net" accept

          # Exception: .11 and .12 may reach 10.100.0.2 over the mesh
          iifname "wg-net" oifname "wg-mesh" ip saddr { 10.200.0.11, 10.200.0.12 } ip daddr 10.100.0.2 accept
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;

          # wg-net client to wg-net client (hairpin through this host)
          iifname "wg-net" oifname "wg-net" masquerade

          # .11 and .12 to 10.100.0.2 over the mesh
          iifname "wg-net" oifname "wg-mesh" ip saddr { 10.200.0.11, 10.200.0.12 } ip daddr 10.100.0.2 masquerade
        }
      }
    '';
  };

}