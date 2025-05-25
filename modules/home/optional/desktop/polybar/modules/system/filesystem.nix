{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/filesystem" = {
          type = "internal/fs";
          interval = 25;
          mount-0 = "/";
          label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%";
          label-unmounted = "%mountpoint% not mounted";
          label-unmounted-foreground = "#FFFFFF";
        };
      };
    };
  };
}