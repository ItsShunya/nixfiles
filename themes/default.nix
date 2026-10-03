# Look of every desktop, system side: fonts and the login screen.
# The user side (program fonts and colors) is in ./home.nix.
{ pkgs, ... }:

let
  wallpaper_src = ../assets/wallpaper;
in
{
  fonts.packages = with pkgs; [
    font-awesome
    fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  services.xserver.displayManager.lightdm = {
    background = "${wallpaper_src}/flying_ships_h.jpg";
    greeters.slick = {
      theme.name = "Arc-Dark"; # example
      iconTheme.name = "Papirus";
      draw-user-backgrounds = false;
    };
  };
}
