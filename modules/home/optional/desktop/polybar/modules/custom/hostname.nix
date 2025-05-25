{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/hostname" = {
          type = "custom/script";
          exec = "cat /etc/hostname";
          interval = 0;
          format = "<label>";
          format-foreground = "#E5E9F0";
          format-background = "#3D0F34";
        };
      };
    };
  };
}