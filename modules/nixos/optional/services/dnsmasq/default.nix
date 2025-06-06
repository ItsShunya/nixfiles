{ config, pkgs, ... }:

{
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    resolveLocalQueries = false;
    settings = {
      listen-address = [ "127.0.0.1" "10.9.97.185" ];
      cache-size = 10000;
      address = [ "/shunya.lan/10.9.97.185" ];
      local = [ "/shunya.lan/" ];
      domain = [ "shunya.lan" ];
      server = [ "8.8.8.8" "8.8.4.4" ];
    };
  };
}
