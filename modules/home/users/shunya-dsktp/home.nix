{ config, pkgs, ... }:

{
  imports = [
    ../../core
    ../../optional/desktop/polybar
    ../../optional/desktop/i3
    ../../optional/programs/alacritty
    ../../optional/programs/picom
    ../../optional/programs/git
    ../../optional/programs/vscode
    ./wallpaper.nix
  ];

  # --- USER ---

  # Home-manager user details.
  home.username = "shunya";
  home.homeDirectory = "/home/shunya";

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
  };

  # --- PACKAGES ---

  home.packages = with pkgs; [
    # Dev tools.
    gitkraken

    # Graphics.
    krita

    nixfmt-rfc-style
  ];

  # --- PROGRAMS ---

}
