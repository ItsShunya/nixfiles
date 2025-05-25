{ config, pkgs, ... }:

{

  imports = [
    ./hardware
    ./nix
    ./shell
    ./system
  ];

}