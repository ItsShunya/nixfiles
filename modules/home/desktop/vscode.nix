{ config, pkgs, ... }:

{
  # VSCode config and extensions.
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
    ];
  };
}
