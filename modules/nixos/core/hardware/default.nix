{ config, pkgs, ... }:

{

  imports = [
    ./audio.nix
    ./keyboard.nix
    ./printer.nix
  ];
  
}