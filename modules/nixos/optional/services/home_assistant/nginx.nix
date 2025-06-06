{ config, pkgs, ... }:

{
  services.home-assistant.config.http = {
    trusted_proxies = [
      "::1"
      "127.0.0.1"
    ];
    use_x_forwarded_for = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."home.shunya.lan" = {
      # forceSSL = true;
      # enableACME = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };
  };
}
