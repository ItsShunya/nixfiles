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
        "module/filesystem" = {
          type = "internal/fs";
          interval = 25;
          mount-0 = "/";
          label-mounted = "%{F${palette.primary}}%mountpoint%%{F-} %percentage_used%%";
          label-unmounted = "%mountpoint% not mounted";
          label-unmounted-foreground = palette.alert;
        };
      };
    };
  };
}
