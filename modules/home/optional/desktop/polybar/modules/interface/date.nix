{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%d %b %l:%M %p";
          date-alt = "%Y-%m-%d %H:%M:%S";
          label = "%date%";
          label-foreground = "#E5E9F0"; #base0A;
          # format-background = "#3D0F34";
        };
      };
    };
  };
}