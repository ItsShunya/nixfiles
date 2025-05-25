{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          format-volume = "<ramp-volume> <label-volume>";
          format-volume-foreground = "#BF616A"; # base 0B
          label-volume = "%percentage%%";
          label-muted = "󰝟 ---";
          label-muted-foreground = "#4C566A"; #base 03
          ramp-volume-0 = "";
          ramp-volume-1 = "󰕾";
          ramp-volume-2 = "";
          # click-right = config.audioSwitchCommand;
        };
      };
    };
  };
}