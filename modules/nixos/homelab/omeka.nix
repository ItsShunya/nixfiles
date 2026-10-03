{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  homelab.proxies.museum.port = 8081;

  systemd.services.docker-omeka-network = {
    description = "Create Docker network for Omeka S";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create omeka-net || true'";
      ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network rm omeka-net || true'";
    };
  };

  # Secrets live encrypted in secrets/<hostname>.yaml under `omeka:`.
  # They're rendered into root-only env files in /run/secrets/rendered.
  sops.secrets = {
    "omeka/db_root_password" = { };
    "omeka/db_password" = { };
    "omeka/admin_password" = { };
  };

  sops.templates."omeka-db.env" = {
    content = ''
      MYSQL_ROOT_PASSWORD=${config.sops.placeholder."omeka/db_root_password"}
      MYSQL_PASSWORD=${config.sops.placeholder."omeka/db_password"}
    '';
    restartUnits = [ "docker-omeka_mariadb.service" ];
  };

  sops.templates."omeka-app.env" = {
    content = ''
      MYSQL_PASSWORD=${config.sops.placeholder."omeka/db_password"}
      OMEKA_ADMIN_PASSWORD=${config.sops.placeholder."omeka/admin_password"}
    '';
    restartUnits = [ "docker-omeka.service" ];
  };

  virtualisation.oci-containers = {
    containers."omeka_mariadb" = {
      autoStart = true;
      image = "mariadb:latest";
      volumes = [
        "omeka_mariadb:/var/lib/mysql"
      ];
      environment = {
        MYSQL_DATABASE = "omeka";
        MYSQL_USER = "omeka";
      };
      environmentFiles = [ config.sops.templates."omeka-db.env".path ];
      extraOptions = [
        "--network=omeka-net"
        "--network-alias=mariadb"
        "--network-alias=db"
      ];
    };

    containers."omeka_pma" = {
      autoStart = true;
      image = "phpmyadmin/phpmyadmin:latest";
      # Localhost only; reach it with `ssh -L 8080:localhost:8080 nb250-10n`.
      ports = [ "127.0.0.1:8080:80" ];
      environment = {
        PMA_HOST = "db";
      };
      extraOptions = [
        "--network=omeka-net"
        "--network-alias=pma"
      ];
    };

    containers."omeka" = {
      autoStart = true;
      image = "giocomai/omeka-s-docker:v4.2.0";
      # Localhost only; served through nginx as museum.shunya.lan.
      ports = [ "127.0.0.1:8081:80" ];
      volumes = [
        "omeka:/var/www/html/volume"
      ];
      environmentFiles = [ config.sops.templates."omeka-app.env".path ];
      environment = {
        MYSQL_USER = "omeka"; # FIXME
        MYSQL_DATABASE = "omeka"; # FIXME
        MYSQL_HOST = "omeka_mariadb";
        APPLICATION_ENV = "development";
        OMEKA_THEMES = ''
          https://github.com/omeka-s-themes/default
          https://github.com/omeka-s-themes/freedom
        '';
        OMEKA_MODULES = ''
          https://github.com/Daniel-KM/Omeka-S-module-Common
          https://github.com/Daniel-KM/Omeka-S-module-EasyAdmin
          https://github.com/Daniel-KM/Omeka-S-module-Adminer
          https://github.com/Daniel-KM/Omeka-S-module-CustomOntology
        '';
        PHP_MEMORY_LIMIT = "512M";
        PHP_UPLOAD_MAX_FILESIZE = "64M";
        PHP_POST_MAX_SIZE = "64M";
        PHP_MAX_EXECUTION_TIME = "300";
        OMEKA_ADMIN_EMAIL = "luque.viictor@gmail.com"; # FIXME
        OMEKA_ADMIN_NAME = "Shunya";
        OMEKA_SITE_TITLE = "Shunya's museum";
      };
      extraOptions = [
        "--network=omeka-net"
        "--network-alias=omeka"
      ];
    };
  };

  systemd.services.docker-omeka_mariadb = {
    after = [
      "docker-omeka-network.service"
      "network-online.target"
    ];
    wants = [
      "docker-omeka-network.service"
      "network-online.target"
    ];
  };

  systemd.services.docker-omeka_pma = {
    after = [
      "docker-omeka_mariadb.service"
      "docker-omeka-network.service"
    ];
    wants = [
      "docker-omeka_mariadb.service"
      "docker-omeka-network.service"
    ];
  };

  systemd.services.docker-omeka = {
    after = [
      "docker-omeka_mariadb.service"
      "docker-omeka-network.service"
    ];
    wants = [
      "docker-omeka_mariadb.service"
      "docker-omeka-network.service"
    ];
  };
}
