{
  config,
  pkgs,
  palette,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  services = {
    polybar = {
      config = {
        "module/wlan" = {
          "inherit" = "network-base";
          interface-type = "wireless";
          label-connected = "%{F${palette.primary}}%ifname%%{F-} %essid% %local_ip%";
        };
      };
    };
  };
}
