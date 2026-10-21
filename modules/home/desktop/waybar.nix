{
  config,
  lib,
  pkgs,
  palette,
  ...
}:

let
  # Asks in rofi (themed in ./rofi.nix) what to do, then does it. Escape
  # closes it doing nothing.
  powerMenu = pkgs.writeShellScript "power-menu" ''
    choice=$(printf '%s\n' "󰌾  Lock" "󰤄  Suspend" "󰍃  Logout" "󰜉  Reboot" "󰐥  Shutdown" \
      | ${config.programs.rofi.finalPackage}/bin/rofi -dmenu -i -no-custom -p "󰐥" \
        -theme-str 'window { width: 280px; } listview { lines: 5; } entry { placeholder: "Power"; }') \
      || exit 0
    case "$choice" in
      *Lock) swaylock -f ;;
      *Suspend) systemctl suspend ;;
      *Logout) niri msg action quit --skip-confirmation ;;
      *Reboot) systemctl reboot ;;
      *Shutdown) systemctl poweroff ;;
    esac
  '';

  # Wraps a Nerd Font icon in the accent color, a size up from the text so it
  # reads at a glance.
  # Icons are Material Design ones (U+F0000 and up, "nf-md-*").
  icon = glyph: "<span color='${palette.primary}' size='larger'>${glyph}</span>";
in
{
  # Status bar for niri: one floating bar over the wallpaper, inset from the
  # screen edges. Colors come from Stylix, the icon accent from the palette.
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
      spacing = 12;

      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu"
        "memory"
        "network"
        "pulseaudio"
        "custom/power"
      ];

      "custom/power" = {
        format = icon "󰐥";
        on-click = "${powerMenu}";
        tooltip = false;
      };

      # One dot per workspace, filled for the active one.
      "niri/workspaces" = {
        format = "<span size='larger'>{icon}</span>";
        format-icons = {
          default = "󰝦";
          active = "󰝥";
        };
      };

      clock = {
        format = "{:%d %b %H:%M}";
        format-alt = "{:%Y-%m-%d %H:%M:%S}";
        interval = 1;
        tooltip = false;
      };

      cpu = {
        interval = 2;
        format = "${icon "󰓅"} {usage:2}%";
      };

      # In GiB, as "5.3GB/31GB".
      memory = {
        interval = 2;
        format = "${icon "󰍛"} {used:0.1f}GB/{total:0.0f}GB";
      };

      network = {
        interval = 5;
        format-ethernet = icon "󰈀";
        format-wifi = "${icon "󰖩"} {essid}";
        format-disconnected = "${icon "󰖪"} <span color='${palette.disabled}'>disconnected</span>";
        tooltip-format = "{ifname}";
      };

      pulseaudio = {
        format = "${icon "{icon}"} {volume}%";
        format-muted = "${icon "󰝟"} <span color='${palette.disabled}'>muted</span>";
        format-icons.default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
      };
    };

    # After Stylix's color definitions (@base00…@base0F) and font.
    style = lib.mkAfter ''
      /* Replaces Stylix's monospace font for the bar. The Propo variant
         gives icons their real width instead of squeezing them into one
         cell, so they no longer run into the text next to them. */
      * {
          font-family: "JetBrainsMono Nerd Font Propo";
          font-weight: 600;
      }

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
      .modules-center > widget > *,
      .modules-right > widget > * {
          padding: 0 8px;
          color: @base05;
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
          color: @base0A;
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
