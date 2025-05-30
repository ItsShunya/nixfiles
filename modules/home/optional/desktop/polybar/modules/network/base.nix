{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "network-base" = {
          type = "internal/network";
          interval = 5;
          format-connected = "<label-connected>";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
        };
      };
    };
  };
}
