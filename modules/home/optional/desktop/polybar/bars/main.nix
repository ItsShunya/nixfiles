{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "bar/main" = {
          bottom = false;
          font-0 = "FantasqueSansMNerdFont Propo:pixelsize=9;3";
          font-1 = "Iosevka Nerd Font:pixelsize=9;2";
          width = "100%";
          height = "12pt";
          radius = 0;
          background = "#3D0F34"; #base01
          foreground = "#E5E9F0"; # base 05
          line-size = "3pt";
          border-top-size = 0;
          border-right-size = 0;
          border-left-size = 0;
          border-bottom-size = "4pt";
          border-color = "#3D0F34"; # base 00
          padding-left = 0;
          padding-right = 1;
          module-margin = 1;
          modules-left = "power date i3";
          modules-center = "xwindow";
          modules-right = "memory cpu eth pulseaudio hostname uname";
          enable-ipc = true;
          separator = "|";
          # tray-position = "right";
          # wm-restack = "i3";
          # override-redirect = true;
        };
      };
    };
  };
}