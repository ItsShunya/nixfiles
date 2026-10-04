{
  config,
  lib,
  pkgs,
  ...
}:

let
  niri = lib.getExe config.programs.niri.package;
in
{
  # Wayland session: the niri compositor, started from the ReGreet greeter.
  # Niri itself is configured in Home Manager (modules/home/desktop/niri.nix).

  # Also brings xdg portals, gnome-keyring, polkit and swaylock's PAM entry.
  programs.niri = {
    enable = true;
    # File dialogs use the GTK portal; Thunar is the file manager.
    useNautilus = false;
  };

  # Display manager --> greetd with the ReGreet greeter. Its look comes from
  # Stylix (themes/default.nix).
  programs.regreet.enable = true;

  # ReGreet runs in its own niri instead of the default cage, which spreads it
  # over every monitor. Hosts append `output` blocks to this config, e.g. to
  # show the login screen on one monitor only. Stylix warns about the custom
  # greetd command; its theme still applies.
  services.greetd.settings.default_session.command =
    "${pkgs.dbus}/bin/dbus-run-session ${niri} -c /etc/greetd/niri.kdl";
  environment.etc."greetd/niri.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "es"
            }
        }
    }

    hotkey-overlay {
        skip-at-startup
    }

    prefer-no-csd

    window-rule {
        open-fullscreen true
    }

    // Quit when ReGreet exits, so greetd can start the session.
    spawn-sh-at-startup "${lib.getExe config.programs.regreet.package}; ${niri} msg action quit --skip-confirmation"
  '';

  # Electron apps (VS Code, GitKraken) run on Wayland instead of Xwayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
