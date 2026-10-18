{ config, pkgs, ... }: {

  # Firewall
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain input {
          type filter hook input priority filter; policy drop;

          # Allow established/related connections
          ct state established,related accept
          # Allow loopback
          iifname "lo" accept

          # wg-mesh: trusted backbone between servers
          iifname "wg-mesh" ip daddr 10.100.0.0/24 accept
          iifname "wg-mesh" drop

          # wg-net: client access network
          iifname "wg-net" ip saddr 10.200.0.12 ip daddr 10.100.0.2 accept
          iifname "wg-net" ip saddr 10.200.0.0/24 ip daddr 10.200.0.0/24 accept
          iifname "wg-net" drop

          # SSH
          tcp dport 1993 accept

          # HTTP/HTTPS
          tcp dport { 80, 443 } accept

          # Port ranges
          tcp dport 25550-25564 accept
          tcp dport 50000-51000 accept
          udp dport 50000-51000 accept

          # mDNS
          udp dport 5353 accept

          # ping
          ip protocol icmp accept
        }

        chain forward {
          type filter hook forward priority filter; policy drop;
          ct state established,related accept

          iifname "wg-net" oifname "wg-net" ip saddr 10.200.0.0/24 ip daddr 10.200.0.0/24 accept

          iifname "wg-net" ip saddr 10.200.0.11 ip daddr 10.100.0.2 accept
          iifname "wg-net" ip saddr 10.200.0.12 ip daddr 10.100.0.2 accept
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100;
          iifname "wg-net" ip saddr 10.200.0.0/24 ip daddr 10.200.0.0/24 masquerade
          iifname "wg-net" ip saddr 10.200.0.11 ip daddr 10.100.0.2 masquerade
          iifname "wg-net" ip saddr 10.200.0.12 ip daddr 10.100.0.2 masquerade
        }
      }
    '';
  };

}