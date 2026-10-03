{ lib, pkgs, ... }:

let
  wallpaper_src = ../../assets/wallpaper;
in
{
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  home.packages = with pkgs; [
    # Dev tools.
    gitkraken

    # Graphics.
    krita

    # NixOS dev.
    nixfmt
    pre-commit
  ];

  # Link the specific wallpapers to the home directory.
  home.file.".wallpaper1".source = "${wallpaper_src}/sky_sunset_h.jpg";
  home.file.".wallpaper2".source = "${wallpaper_src}/city_sunset_v.jpg";

  xsession.windowManager.i3.config.startup = lib.mkMerge [
    # Monitor layout first, before the bar and compositor start.
    (lib.mkBefore [
      {
        # Rotated left monitor (DP-2) with DP-1 to its right.
        command = "xrandr --output DP-2 --rotate left --output DP-1 --right-of DP-2";
        always = true;
        notification = false;
      }
    ])
    [
      {
        # This requires a delay otherwise the resolution is not set correctly by feh.
        # feh follows xrandr monitor order (DP-1 is 0, DP-2 is 1), not screen position.
        command = "sleep 2 && ${pkgs.feh}/bin/feh --bg-scale ~/.wallpaper1 ~/.wallpaper2";
        always = true;
        notification = false;
      }
    ]
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  # NOTE: Only update it on clean installs.
  home.stateVersion = "25.11";
}
