{ config, pkgs, ... }:

{

  imports = [
    ./bootloader
    ./nix
    ./shell
  ];

}