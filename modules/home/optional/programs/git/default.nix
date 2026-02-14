{ config, pkgs, ... }:

{
  # Basic configuration of git.
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Victor Luque";
        email = "luque.viictor@gmail.com";
      };
    };
  };
}
