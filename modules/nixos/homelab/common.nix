# Shared base for the homelab services: Docker for the containers and an
# nginx reverse proxy serving each one as <name>.<domain> on port 80.
# Every service module imports this and registers itself in
# `homelab.proxies`.
{ config, lib, ... }:

let
  cfg = config.homelab;
in
{
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "shunya.lan";
      description = "LAN domain the services are served under.";
    };

    proxies = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.port = lib.mkOption {
            type = lib.types.port;
            description = "Local port the service listens on.";
          };
        }
      );
      default = { };
      description = "Services to proxy, served as <name>.<domain>.";
    };
  };

  config = {
    virtualisation.oci-containers.backend = "docker";
    users.users.shunya.extraGroups = [ "docker" ];

    networking.firewall.allowedTCPPorts = [ 80 ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;

      virtualHosts = lib.mapAttrs' (
        name: proxy:
        lib.nameValuePair "${name}.${cfg.domain}" {
          # forceSSL = true;
          # enableACME = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString proxy.port}";
            proxyWebsockets = true;
          };
        }
      ) cfg.proxies;
    };
  };
}
