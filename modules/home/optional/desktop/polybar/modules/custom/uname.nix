{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/uname" = {
          type = "custom/script";
          exec = "echo $(uname) $(uname -r | tr - . | cut -d. -f1-2)";
          interval = 0;
          format = "<label>";
          format-foreground = "#E5E9F0";
          format-background = "#3D0F34";
        };
      };
    };
  };
}