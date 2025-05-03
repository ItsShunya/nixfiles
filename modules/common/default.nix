{ config, pkgs, ... }:

{

  imports = [
    ../nixos/core     # Common for all hosts.
    ./packages.nix
  ];
  
}