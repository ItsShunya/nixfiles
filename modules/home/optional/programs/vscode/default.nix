{ config, pkgs, ... }:

{
  # VSCode config and extensions.
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
    ];
  };
}