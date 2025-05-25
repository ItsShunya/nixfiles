{ config, pkgs, ... }:
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
          label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
        };
      };
    };
  };
}
