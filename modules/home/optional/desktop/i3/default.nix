{ config, pkgs, ... }:

{

  imports = [
    ./i3wm/i3wm.nix
    ./picom
  ];
  
}