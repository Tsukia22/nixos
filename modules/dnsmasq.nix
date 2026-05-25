{ config, pkgs, ... }: {

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      interface = "wg-net";
      bind-interfaces = true;
      no-resolv = true;
      no-poll = true;
      expand-hosts = true;
      address = [
        "/xan.xan/10.200.0.1"
        "/xan.lan/10.200.0.1"
        "/xan.wg/10.200.0.1"
        "/xan.vpn/10.200.0.1"
        "/x.x/10.200.0.1"
        "/xan.internal/10.200.0.1"
        "/tsu.tsu/10.200.0.3"
        "/tsu.lan/10.200.0.3"
        "/tsu.wg/10.200.0.2"
        "/tsu.vpn/10.200.0.3"
        "/t.t/10.200.0.3"
        "/tsu.internal/10.200.0.3"
      ];
    };
  };

}