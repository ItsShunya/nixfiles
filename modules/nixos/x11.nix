{ lib, pkgs, ... }:

let
  wallpaper_src = ../../assets/wallpaper;
in
{
  # Session helpers used by the i3 setup.
  users.users.shunya.packages = with pkgs; [
    gnome-keyring
    polkit_gnome
    clipmenu
    lightlocker # Session-locker for XFCE workaround.
  ];

  fonts.packages = with pkgs; [
    font-awesome
    fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

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
            theme.name = "Arc-Dark"; # example
            iconTheme.name = "Papirus";
            draw-user-backgrounds = false;
            extraConfig = ''
              show-hostname=true
              show-keyboard=false
              show-a11y=false
              show-power=false
              only-on-monitor=0
            '';
          };
          background = "${wallpaper_src}/flying_ships_h.jpg";
        };
      };
    };

    displayManager.defaultSession = "xfce+i3";
  };

  # --- PROGRAMS ---

  programs = {
    thunar.enable = true;
    dconf.enable = true; # Necessary to save some configs after reboot.
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
}
