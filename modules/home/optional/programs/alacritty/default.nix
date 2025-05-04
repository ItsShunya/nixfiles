{ config, pkgs, ... }:

{ 

  home.packages = with pkgs; [
    alacritty
  ];

  # Link the specific Alacritty config.
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;

}