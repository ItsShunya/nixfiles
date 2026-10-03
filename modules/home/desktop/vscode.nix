{ config, pkgs, ... }:

{
  # VSCode itself. Extensions, including the Catppuccin theme, are installed
  # from the marketplace; see themes/home.nix for why not from here.
  programs.vscode = {
    enable = true;
  };
}
