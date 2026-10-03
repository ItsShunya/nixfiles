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
        "module/eth" = {
          "inherit" = "network-base";
          interface-type = "wired";
          label-connected = "%{F${palette.primary}}%ifname%%{F-} %local_ip%";
        };
      };
    };
  };
}
