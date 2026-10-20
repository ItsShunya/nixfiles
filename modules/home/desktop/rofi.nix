{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag;
in
{
  # App launcher (Mod+D in niri) and the bar's power menu. rofi 2 runs on
  # Wayland natively. The theme below matches the bar: the same translucent
  # background, border and corners, with the blue accent of the active
  # workspace. Stylix's rofi target stays off, as it would replace it.
  programs.rofi = {
    enable = true;
    terminal = "alacritty";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      icon-theme = config.stylix.icons.dark;
      display-drun = "󰀻";
      display-run = "󰆍";
      drun-display-format = "{name}";
    };

    # The bar's alpha(@base00, 0.85) and alpha(@base03, 0.5) are d9 and 80 here.
    theme = toString (pkgs.writeText "rofi-theme.rasi" ''
      * {
          font: "${config.stylix.fonts.monospace.name} 12";
          background-color: transparent;
          text-color: ${c.base05};
      }

      window {
          location: center;
          width: 560px;
          padding: 12px;
          background-color: ${c.base00}d9;
          border: 1px;
          border-color: ${c.base03}80;
          border-radius: 6px;
      }

      mainbox {
          spacing: 10px;
          children: [ inputbar, message, listview ];
      }

      inputbar {
          padding: 8px 10px;
          spacing: 10px;
          background-color: ${c.base01};
          border-radius: 4px;
          children: [ prompt, entry ];
      }

      prompt {
          text-color: ${c.base0D};
      }

      entry {
          placeholder: "Search";
          placeholder-color: ${c.base03};
          cursor: text;
      }

      message {
          padding: 6px 10px;
          background-color: ${c.base01};
          border-radius: 4px;
      }

      listview {
          lines: 8;
          fixed-height: true;
          scrollbar: false;
          spacing: 2px;
      }

      element {
          padding: 6px 10px;
          spacing: 10px;
          border-radius: 4px;
          cursor: pointer;
      }

      element selected.normal {
          background-color: ${c.base02};
          text-color: ${c.base0D};
      }

      element-icon {
          size: 1.2em;
          vertical-align: 0.5;
      }

      element-text {
          vertical-align: 0.5;
          text-color: inherit;
          highlight: bold ${c.base0D};
      }
    '');
  };
}
