{ config, pkgs, ... }:

{
  imports = [
    ../shared
  ];

  # Home-manager user details.
  home.username = "shunya";
  home.homeDirectory = "/home/shunya";

  # Basic configuration of git.
  programs.git = {
    enable = true;
    userName = "Victor Luque";
    userEmail = "luque.viictor@gmail.com";
  };  
}
