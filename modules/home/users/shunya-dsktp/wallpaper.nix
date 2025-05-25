{ config, pkgs, ... }:

let
  wallpaper_src = ../../../../bin/images/wallpaper;
in
{

  # Link the specific wallpapers to the home directory.
  home.file.".wallpaper1".source = "${wallpaper_src}/sky_sunset_h.jpg";
  home.file.".wallpaper2".source = "${wallpaper_src}/city_sunset_v.jpg";

}
