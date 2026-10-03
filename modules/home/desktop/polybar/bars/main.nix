{
  config,
  pkgs,
  palette,
  ...
}:
{
  services = {
    polybar = {
      config = {
        # Fonts are set in themes/home.nix.
        "bar/main" = {
          bottom = false;
          width = "100%";
          height = "12pt";
          radius = 0;
          background = palette.background;
          foreground = palette.foreground;
          line-size = "3pt";
          border-top-size = 0;
          border-right-size = 0;
          border-left-size = 0;
          border-bottom-size = "4pt";
          border-color = palette.background;
          padding-left = 0;
          padding-right = 1;
          module-margin = 1;
          modules-left = "power date i3";
          modules-center = "xwindow";
          modules-right = "memory cpu eth pulseaudio hostname uname";
          enable-ipc = true;
          separator = "|";
          # tray-position = "right";
          # wm-restack = "i3";
          # override-redirect = true;
        };
      };
    };
  };
}
