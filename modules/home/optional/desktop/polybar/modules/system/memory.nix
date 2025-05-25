{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = "RAM ";
          format-prefix-foreground = "#E5E9F0"; #base06
          label = "%percentage_used:2%%";
        };
      };
    };
  };
}