{
  imports = [ ./common.nix ];

  homelab.proxies.home.port = 8123;

  virtualisation.oci-containers.containers."homeassistant" = {
    autoStart = true;
    volumes = [ "home-assistant:/config" ];
    environment.TZ = "Europe/Paris";
    image = "ghcr.io/home-assistant/home-assistant:2026.2.2";
    extraOptions = [
      "--network=host"
      "--privileged"
    ];
  };
}
