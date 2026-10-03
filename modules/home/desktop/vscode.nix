{ config, pkgs, ... }:

{
  # VSCode config and extensions. Its color theme is in themes/home.nix.
  programs.vscode = {
    enable = true;
  };
}
