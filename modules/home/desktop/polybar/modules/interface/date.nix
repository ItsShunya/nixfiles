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
        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%d %b %l:%M %p";
          date-alt = "%Y-%m-%d %H:%M:%S";
          label = "%date%";
          label-foreground = palette.foreground;
          # format-background = palette.background;
        };
      };
    };
  };
}
