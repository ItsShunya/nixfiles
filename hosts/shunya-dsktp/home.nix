{ pkgs, ... }:

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
