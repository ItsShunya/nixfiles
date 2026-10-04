{ palette, ... }:

{
  # Status bar for niri, with the same segments as Polybar on i3. Colors and
  # fonts come from Stylix; the per-segment accents from the palette.
  programs.waybar = {
    enable = true;
    # Started and stopped with the niri session.
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 22;
      spacing = 4;

      modules-left = [
        "custom/power"
        "clock"
        "niri/workspaces"
      ];
      modules-center = [ "niri/window" ];
      modules-right = [
        "memory"
        "cpu"
        "network"
        "pulseaudio"
        "custom/hostname"
        "custom/uname"
      ];

      "custom/power" = {
        format = "";
        tooltip = false;
      };

      clock = {
        format = "{:%d %b %l:%M %p}";
        format-alt = "{:%Y-%m-%d %H:%M:%S}";
        interval = 1;
      };

      "niri/window" = {
        max-length = 60;
      };

      memory = {
        interval = 2;
        format = "RAM {percentage:2}%";
      };

      cpu = {
        interval = 2;
        format = "CPU {usage:2}%";
      };

      network = {
        interval = 5;
        format-ethernet = "<span color='${palette.primary}'>{ifname}</span> {ipaddr}";
        format-wifi = "<span color='${palette.primary}'>{ifname}</span> {essid} {ipaddr}";
        format-disconnected = "<span color='${palette.disabled}'>disconnected</span>";
      };

      pulseaudio = {
        format = "<span color='${palette.volume}'>{icon} {volume}%</span>";
        format-muted = "<span color='${palette.volume-muted}'>󰝟 ---</span>";
        format-icons.default = [
          ""
          "󰕾"
          ""
        ];
      };

      "custom/hostname" = {
        exec = "cat /etc/hostname";
        interval = "once";
      };

      "custom/uname" = {
        exec = "echo $(uname) $(uname -r | tr - . | cut -d. -f1-2)";
        interval = "once";
      };
    };
  };
}
