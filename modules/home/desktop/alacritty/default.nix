{ config, pkgs, ... }:

{

  # Environment
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  # Home Manager writes ~/.config/alacritty/alacritty.toml with the colors and
  # font from Stylix (themes/), and it imports the hand-written alacritty.toml.
  programs.alacritty = {
    enable = true;
    settings.general.import = [ "${./alacritty.toml}" ];
  };

}
