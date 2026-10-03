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
        "module/hostname" = {
          type = "custom/script";
          exec = "cat /etc/hostname";
          interval = 0;
          format = "<label>";
          format-foreground = palette.foreground;
          format-background = palette.background;
        };
      };
    };
  };
}
