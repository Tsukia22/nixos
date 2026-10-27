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

          # SSH
          tcp dport 1993 accept

          # Port ranges
          tcp dport 25560-25564 accept

          # mDNS
          udp dport 5353 accept

          # ping
          ip protocol icmp accept
        }
      }
    '';
  };

}