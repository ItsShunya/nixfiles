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
        "network-base" = {
          type = "internal/network";
          interval = 5;
          format-connected = "<label-connected>";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "%{F${palette.primary}}%ifname%%{F${palette.disabled}} disconnected";
        };
      };
    };
  };
}
