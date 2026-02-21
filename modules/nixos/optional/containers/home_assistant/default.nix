{ config, pkgs, ... }:

{
  imports = [
    ./nginx.nix
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers."homeassistant" = {
      autoStart = true;
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Paris";
      image = "ghcr.io/home-assistant/home-assistant:2026.2.2";
      extraOptions = [
        "--network=host"
        "--privileged"
      ];
    };
  };
}
