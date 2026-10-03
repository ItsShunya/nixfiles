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
        "module/xkeyboard" = {
          type = "internal/xkeyboard";
          blacklist-0 = "num lock";
          label-layout = "%layout%";
          label-layout-foreground = palette.background;
          label-indicator-padding = 2;
          label-indicator-margin = 1;
          label-indicator-foreground = palette.foreground;
          label-indicator-background = palette.background;
        };
      };
    };
  };
}
