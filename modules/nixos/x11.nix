{ lib, pkgs, ... }:

{
  # Session helpers used by the i3 setup.
  users.users.shunya.packages = with pkgs; [
    gnome-keyring
    polkit_gnome
    clipmenu
    lightlocker # Session-locker for XFCE workaround.
  ];

  # Fonts and the greeter's look are in themes/default.nix.

  # --- SERVICES ---

  services = {

    # Window System.
    xserver = {
      enable = true;

      # Keyboard config.
      xkb = {
        layout = "es";
        variant = "";
      };

      # Window manager --> i3wm.
      # Configured in Home Manager profile.
      windowManager.i3 = {
        enable = true;
      };

      # Keep Xfce active (no GUI) for tools.
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableScreensaver = false;
          enableXfwm = false;
        };
      };

      # Display manager --> lightDM.
      displayManager = {
        lightdm = {
          enable = true;
          greeter.enable = true;
          greeters.gtk.enable = false;
          greeters.mini.enable = false;
          greeters.slick = {
            enable = lib.mkForce true;
            extraConfig = ''
              show-hostname=true
              show-keyboard=false
              show-a11y=false
              show-power=false
              only-on-monitor=0
            '';
          };
        };
      };
    };

    displayManager.defaultSession = "xfce+i3";
  };
}
