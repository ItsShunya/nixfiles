{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format-prefix = "CPU ";
          format-prefix-foreground = "#E5E9F0";
          label = "%percentage:2%%";
        };
      };
    };
  };
}