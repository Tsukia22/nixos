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
      server = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
        "1.1.1.1"
        "8.8.8.8"
      ];
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
      srv-host = [
        "_minecraft._tcp.greg.tsu,t.t,50400,0,5"
      ];
    };
  };

  # Avoid race condition on boot
  systemd.services.dnsmasq = {
    after = [ "sys-subsystem-net-devices-wg-net.device" ];
    wants = [ "sys-subsystem-net-devices-wg-net.device" ];
  };

}