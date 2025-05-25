{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/i3" = {
          type = "internal/i3";
          # pin-workspaces = true;
          show-urgent = true;
          strip-wsnumbers = true;
          index-sort = true;
          enable-click = true;
          wrapping-scroll = true;
          fuzzy-match = true;
          format = "<label-state> <label-mode>";
          label-focused = "%name%";
          label-focused-foreground = "#3D0F34"; #base01
          label-focused-background = "#E5E9F0"; # base 05
          label-focused-padding = 1;
          label-unfocused = "%name%";
          label-unfocused-padding = 1;
          label-visible = "%name%";
          label-visible-padding = 1;
          label-urgent = "%name%";
          label-urgent-foreground = "#2E3440"; # base 00
          label-urgent-background = "#88C0D0"; #base 08
          label-urgent-padding = 1;
        };
      };
    };
  };

}