{ config, pkgs, ... }:

{
  imports = [
    ./nginx.nix
  ];

  virtualisation.oci-containers = {
    backend = "docker";

    containers."fava" = {
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
        "--privileged"
      ];
    };
  };
}


