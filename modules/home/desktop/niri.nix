{
  lib,
  pkgs,
  palette,
  ...
}:

let
  wpctl = "${pkgs.wireplumber}/bin/wpctl";

  # Mod+N focuses workspace N, Mod+Shift+N moves the column there.
  workspaceBinds = lib.concatMapStringsSep "\n    " (
    n: "Mod+${n} { focus-workspace ${n}; }\n    Mod+Shift+${n} { move-column-to-workspace ${n}; }"
  ) (map toString (lib.range 1 9));
in
{
  # Home Manager has no niri module, so the config is written as KDL. The
  # option is a list of lines: hosts append their outputs and wallpapers to
  # it from hosts/<name>/home.nix. See `niri validate` for syntax errors.
  # Docs: https://yalter.github.io/niri/Configuration:-Introduction
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "es"
            }
        }
        focus-follows-mouse
    }

    // Window colors come from the palette (themes/palette.nix).
    layout {
        gaps 10
        default-column-width { proportion 0.5; }
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }
        focus-ring { off; }
        border {
            width 3
            active-color "${palette.border-active}"
            inactive-color "${palette.border-inactive}"
            urgent-color "${palette.border-urgent}"
        }
        shadow { on; }
    }

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    hotkey-overlay {
        skip-at-startup
    }

    // Translucent Alacritty, as picom does on i3.
    window-rule {
        match app-id="^Alacritty$"
        opacity 0.91
    }
    window-rule {
        match app-id="^Alacritty$" is-focused=false
        opacity 0.81
    }

    spawn-at-startup "firefox"

    binds {
        Mod+F1 { show-hotkey-overlay; }

        Mod+Return hotkey-overlay-title="Open a terminal: alacritty" { spawn "alacritty"; }
        Mod+D hotkey-overlay-title="Run an application: fuzzel" { spawn "fuzzel"; }
        Mod+X hotkey-overlay-title="Screenshot to clipboard" { screenshot; }
        Mod+Shift+X hotkey-overlay-title="Lock the screen: swaylock" { spawn-sh "swaylock -f && niri msg action power-off-monitors"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05-"; }
        XF86AudioMute allow-when-locked=true { spawn-sh "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Shift+Q repeat=false { close-window; }

        // Focus
        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }

        // Move
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Home { move-column-to-first; }
        Mod+Shift+End { move-column-to-last; }

        // Monitors
        Mod+Alt+Left { focus-monitor-left; }
        Mod+Alt+Right { focus-monitor-right; }
        Mod+Control+Left { move-workspace-to-monitor-left; }
        Mod+Control+Right { move-workspace-to-monitor-right; }

        // Workspaces
        ${workspaceBinds}
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }
        Mod+Shift+Page_Up { move-column-to-workspace-up; }
        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

        // Columns
        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }
        Mod+W { toggle-column-tabbed-display; }
        Mod+R { switch-preset-column-width; }
        Mod+M { maximize-column; }
        Mod+F { fullscreen-window; }
        Mod+C { center-column; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Plus { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Plus { set-window-height "+10%"; }

        // Floating
        Mod+Shift+Space { toggle-window-floating; }
        Mod+Space { switch-focus-between-floating-and-tiling; }

        // Session
        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }
    }
  '';

  home.packages = with pkgs; [
    # Runs X11 programs (Krita…); niri starts it on demand.
    xwayland-satellite
    wl-clipboard
  ];

  # Launcher, lock screen and notifications. Their look comes from Stylix.
  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;
  services.mako.enable = true;

  # Niri has no polkit agent of its own; this one asks for passwords when an
  # app needs root (mounting a disk from Thunar…).
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
