{
  config,
  pkgs,
  palette,
  ...
}:
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
          label-focused-foreground = palette.background;
          label-focused-background = palette.foreground;
          label-focused-padding = 1;
          label-unfocused = "%name%";
          label-unfocused-padding = 1;
          label-visible = "%name%";
          label-visible-padding = 1;
          label-urgent = "%name%";
          label-urgent-foreground = palette.urgent-foreground;
          label-urgent-background = palette.urgent-background;
          label-urgent-padding = 1;
        };
      };
    };
  };

}
