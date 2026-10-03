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
        "module/power" = {
          type = "custom/text";
          content = "  ";
          #click-left = config.powerCommand;
          content-foreground = palette.foreground;
        };
      };
    };
  };
}
