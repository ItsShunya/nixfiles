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
        "module/whoami" = {
          type = "custom/script";
          exec = "whoami";
          interval = 0;
          format = "<label>";
          format-foreground = palette.foreground;
          format-background = palette.background;
        };
      };
    };
  };
}
