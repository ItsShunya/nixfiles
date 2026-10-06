{ lib, palette, ... }:

let
  # Wraps a Nerd Font icon in the accent color, before the module's text.
  # Icons are Material Design ones (U+F0000 and up, "nf-md-*").
  icon = glyph: "<span color='${palette.primary}'>${glyph}</span>";
in
{
  # Status bar for niri: one floating bar over the wallpaper, inset from the
  # screen edges. Colors and fonts come from Stylix; the icon accents from
  # the palette.
  programs.waybar = {
    enable = true;
    # Started and stopped with the niri session.
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 30;
      # Floats 10px from the screen edges, the same as niri's window gaps.
      margin-top = 10;
      margin-left = 10;
      margin-right = 10;
      spacing = 2;

      modules-left = [
        "custom/power"
        "niri/workspaces"
        "clock"
      ];
      modules-right = [
        "cpu"
        "memory"
        "network"
        "pulseaudio"
        "custom/hostname"
        "custom/uname"
      ];

      "custom/power" = {
        format = "󰐥";
        tooltip = false;
      };

      # One dot per workspace, filled for the active one.
      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = "󰝦";
          active = "󰝥";
        };
      };

      clock = {
        format = "${icon "󰥔"} {:%d %b %I:%M %p}";
        format-alt = "${icon "󰥔"} {:%Y-%m-%d %H:%M:%S}";
        interval = 1;
        tooltip = false;
      };

      cpu = {
        interval = 2;
        format = "${icon "󰻠"} {usage:2}%";
      };

      memory = {
        interval = 2;
        format = "${icon "󰍛"} {percentage:2}%";
      };

      network = {
        interval = 5;
        format-ethernet = "${icon "󰈀"} {ipaddr}";
        format-wifi = "${icon "󰖩"} {essid} {ipaddr}";
        format-disconnected = "<span color='${palette.disabled}'>󰖪 disconnected</span>";
        tooltip-format = "{ifname}";
      };

      pulseaudio = {
        format = "<span color='${palette.volume}'>{icon}</span> {volume}%";
        format-muted = "<span color='${palette.volume-muted}'>󰝟 muted</span>";
        format-icons.default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
      };

      "custom/hostname" = {
        exec = "cat /etc/hostname";
        format = "${icon "󰍹"} {}";
        interval = "once";
        tooltip = false;
      };

      "custom/uname" = {
        exec = "echo $(uname -r | tr - . | cut -d. -f1-2)";
        format = "${icon "󰌽"} {}";
        interval = "once";
        tooltip = false;
      };
    };

    # After Stylix's color definitions (@base00…@base0F) and font.
    style = lib.mkAfter ''
      window#waybar {
          background: alpha(@base00, 0.85);
          border: 1px solid alpha(@base03, 0.5);
          border-radius: 6px;
      }

      .modules-left,
      .modules-right {
          padding: 0 6px;
      }

      .modules-left > widget > *,
      .modules-right > widget > * {
          padding: 0 8px;
          color: @base05;
      }

      #custom-power {
          color: @base0D;
          padding: 0 10px 0 6px;
      }

      #workspaces {
          padding: 0 4px;
      }

      #workspaces button {
          padding: 0 5px;
          min-width: 0;
          color: @base03;
          background: transparent;
          border: none;
          border-radius: 4px;
          box-shadow: none;
      }

      #workspaces button:hover {
          color: @base05;
          background: alpha(@base02, 0.6);
      }

      #workspaces button.active {
          color: @base0D;
      }

      #workspaces button.urgent {
          color: @base08;
      }

      tooltip {
          background: alpha(@base00, 0.95);
          border: 1px solid @base02;
          border-radius: 6px;
      }

      tooltip label {
          color: @base05;
      }
    '';
  };

  # The style above replaces Stylix's, which underlines workspaces and
  # paints the whole bar.
  stylix.targets.waybar.addCss = false;
}
