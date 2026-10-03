{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/whoami" = {
          type = "custom/script";
          exec = "whoami";
          interval = 0;
          format = "<label>";
          format-foreground = "#E5E9F0";
          format-background = "#3D0F34";
        };
      };
    };
  };
}
