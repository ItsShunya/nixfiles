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
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          format-volume = "<ramp-volume> <label-volume>";
          format-volume-foreground = palette.volume;
          label-volume = "%percentage%%";
          label-muted = "󰝟 ---";
          label-muted-foreground = palette.volume-muted;
          ramp-volume-0 = "";
          ramp-volume-1 = "󰕾";
          ramp-volume-2 = "";
          # click-right = config.audioSwitchCommand;
        };
      };
    };
  };
}
