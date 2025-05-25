{ config, pkgs, ... }:

{
  imports = [
    ../../core
    ../../optional/programs/git
  ];

  # --- USER ---

  # Home-manager user details.
  home.username = "shunya";
  home.homeDirectory = "/home/shunya";

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
  };


  # --- PACKAGES ---

  home.packages = with pkgs; [

  ];


  # --- PROGRAMS ---

}
