{ config, pkgs, ... }:

{
  imports = [
    ./nginx.nix
  ];

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

  virtualisation.oci-containers = {
    backend = "docker";

    containers."omeka_mariadb" = {
      autoStart = true;
      image = "mariadb:latest";
      volumes = [
        "omeka_mariadb:/var/lib/mysql"
      ];
      environment = {
        MYSQL_ROOT_PASSWORD = "blabla";  # FIXME
        MYSQL_DATABASE = "omeka";
        MYSQL_USER = "omeka";
        MYSQL_PASSWORD = "omeka";        # FIXME
      };
      extraOptions = [
        "--network=omeka-net"
        "--network-alias=mariadb"
        "--network-alias=db"
      ];
    };

    containers."omeka_pma" = {
      autoStart = true;
      image = "phpmyadmin/phpmyadmin:latest";
      ports = [ "8080:80" ];
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
      image = "giocomai/omeka-s-docker:v4.1.1";
      ports = [ "8081:80" ];
      volumes = [
        "omeka:/var/www/html/volume"
      ];
      environment = {
        MYSQL_USER = "omeka";            # FIXME
        MYSQL_PASSWORD = "omeka";      # FIXME
        MYSQL_DATABASE = "omeka";        # FIXME
        MYSQL_HOST = "omeka_mariadb";
        APPLICATION_ENV = "development";
        OMEKA_THEMES = "https://github.com/omeka-s-themes/default";
        OMEKA_MODULES = ''
          https://github.com/Daniel-KM/Omeka-S-module-Common
          https://github.com/Daniel-KM/Omeka-S-module-EasyAdmin
          https://github.com/Daniel-KM/Omeka-S-module-Adminer
        '';
        PHP_MEMORY_LIMIT = "512M";
        PHP_UPLOAD_MAX_FILESIZE = "64M";
        PHP_POST_MAX_SIZE = "64M";
        PHP_MAX_EXECUTION_TIME = "300";
        OMEKA_ADMIN_EMAIL = "luque.viictor@gmail.com"; # FIXME
        OMEKA_ADMIN_NAME = "Shunya";
        OMEKA_ADMIN_PASSWORD = "12345";    # FIXME
        OMEKA_SITE_TITLE = "Shunya's museum";
      };
      extraOptions = [
        "--network=omeka-net"
        "--network-alias=omeka"
      ];
    };
  };

  systemd.services.docker-omeka_mariadb = {
    after = [ "docker-omeka-network.service" "network-online.target" ];
    wants = [ "docker-omeka-network.service" "network-online.target" ];
  };

  systemd.services.docker-omeka_pma = {
    after = [ "docker-omeka_mariadb.service" "docker-omeka-network.service" ];
    wants = [ "docker-omeka_mariadb.service" "docker-omeka-network.service" ];
  };

  systemd.services.docker-omeka = {
    after = [ "docker-omeka_mariadb.service" "docker-omeka-network.service" ];
    wants = [ "docker-omeka_mariadb.service" "docker-omeka-network.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 8081 8080 ];
}
