{ config, pkgs, ... }:
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
          label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
        };
      };
    };
  };
}
