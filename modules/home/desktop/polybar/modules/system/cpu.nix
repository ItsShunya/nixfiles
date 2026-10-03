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
        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format-prefix = "CPU ";
          format-prefix-foreground = palette.foreground;
          label = "%percentage:2%%";
        };
      };
    };
  };
}
