{ config, pkgs, ... }:
{
  services = {
    polybar = {
      package = pkgs.polybar.override {
        pulseSupport = true;
        i3Support = true;
      };
      config = {
        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = false;
        };
      };
    };
  };
}