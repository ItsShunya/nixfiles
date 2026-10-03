{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/xkeyboard" = {
          type = "internal/xkeyboard";
          blacklist-0 = "num lock";
          label-layout = "%layout%";
          label-layout-foreground = "#3D0F34";
          label-indicator-padding = 2;
          label-indicator-margin = 1;
          label-indicator-foreground = "#E5E9F0";
          label-indicator-background = "#3D0F34";
        };
      };
    };
  };
}
