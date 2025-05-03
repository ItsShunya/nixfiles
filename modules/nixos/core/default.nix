{ config, pkgs, ... }:

{

  imports = [
    ./bootloader
    ./hardware
    ./nix
    ./shell
    ./system
  ];

}