{
  imports = [ ./common.nix ];

  homelab.proxies.fava.port = 5000;

  virtualisation.oci-containers.containers."finance" = {
    autoStart = true;

    volumes = [
      "/home/shunya/finance-tracker/ledger:/data"
    ];

    environment = {
      TZ = "Europe/Paris";
    };

    image = "ghcr.io/itsshunya/finance-tracker:release";

    extraOptions = [
      "--network=host"
    ];
  };
}
