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
        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = "RAM ";
          format-prefix-foreground = palette.foreground;
          label = "%percentage_used:2%%";
        };
      };
    };
  };
}
