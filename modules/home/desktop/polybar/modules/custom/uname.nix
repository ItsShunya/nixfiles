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
        "module/uname" = {
          type = "custom/script";
          exec = "echo $(uname) $(uname -r | tr - . | cut -d. -f1-2)";
          interval = 0;
          format = "<label>";
          format-foreground = palette.foreground;
          format-background = palette.background;
        };
      };
    };
  };
}
