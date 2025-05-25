{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:60:...%";
        };
      };
    };
  };
}
