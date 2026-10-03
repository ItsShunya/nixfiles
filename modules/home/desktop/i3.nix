{
  config,
  lib,
  pkgs,
  palette,
  ...
}:

let
  mod = "Mod4";
in
{
  xsession.windowManager.i3 = {
    enable = true;

    package = pkgs.i3;

    config = {
      modifier = mod;

      # Fonts and window colors come from Stylix (themes/).

      terminal = "alacritty";

      window = {
        titlebar = false;
        border = 3;
        hideEdgeBorders = "smart";
      };

      floating = {
        border = 2;
      };

      # Polybar replaces i3bar.
      bars = [ ];

      focus = {
        followMouse = true;
        wrapping = "force";
      };

      gaps = {
        bottom = 5;
        horizontal = 5;
        inner = 5;
        left = 5;
        outer = 5;
        right = 5;
        top = 5;
        vertical = 5;
        smartBorders = "no_gaps";
        smartGaps = true;
      };

      # Monitor layout and wallpaper are set per host, in hosts/<name>/home.nix.
      startup = [
        {
          command = "firefox";
        }
      ];

      keybindings = lib.mkOptionDefault {
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+p" = "exec ${pkgs.rofi}/bin/rofi";
        "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        "${mod}+Shift+x" =
          "exec sh -c '${pkgs.i3lock}/bin/i3lock -c ${lib.removePrefix "#" palette.lock} & sleep 5 && xset dpms force off'";

        # Focus
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        # Move
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        # My dual monitor setup
        "${mod}+Control+Right" = "move workspace to output right";
        "${mod}+Control+Left" = "move workspace to output left";
      };
    };
  };

}
