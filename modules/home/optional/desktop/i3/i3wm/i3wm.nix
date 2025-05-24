{ config, lib, pkgs, ... }:

let 
  mod = "Mod4";
in {
  xsession.windowManager.i3 = {
    enable = true;
    
    package = pkgs.i3-gaps;

    config = {
      modifier = mod;

      fonts = ["DejaVu Sans Mono, FontAwesome 6"];

      terminal = "alacritty";

      window = {
        titlebar = false;
        border = 3;
        hideEdgeBorders = "smart";
      };

      floating = {
        border = 2;
      };
      
      bars = [
        #{
        #  position = "top";
        #  statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${../i3status/i3status-rust.toml}";
        #}
      ];

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

      startup = [
        {
          command = "firefox";
        } 
        {
          command = "picom -f &";
          always = true;
          notification = false;
        } 
        {
          # This requires a delay otherwise the resolution is not set correctly by feh.
          command = "sleep 2 && ${pkgs.feh}/bin/feh --bg-scale ~/.wallpaper1 ~/.wallpaper2"; 
          always = true;
          notification = false;
        }
      ];

      keybindings = lib.mkOptionDefault {
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+p" = "exec ${pkgs.rofi}/bin/rofi";
        "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        "${mod}+Shift+x" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";

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

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  #home.file.".config/i3/config" = {
  #  source = ./i3config;
  #  onChange = ''
  #    ~{pkgs.i3}/bin/i3-msg reload
  #  '';
  #};
}