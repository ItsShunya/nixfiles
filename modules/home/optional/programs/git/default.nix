{ config, pkgs, ... }:

{
  # Basic configuration of git.
  programs.git = {
    enable = true;
    userName = "Victor Luque";
    userEmail = "luque.viictor@gmail.com";
  };
}
