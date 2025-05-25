{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/power" = {
          type = "custom/text";
          content = "  ";
          #click-left = config.powerCommand;
          content-foreground = "#E5E9F0"; #base04
        };
      };
    };
  };
}