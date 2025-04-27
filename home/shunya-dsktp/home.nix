{ config, pkgs, ... }:

{
  imports = [
    ../shared
  ];

  # Home-manager user details.
  home.username = "shunya";
  home.homeDirectory = "/home/shunya";

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  # Basic configuration of git.
  programs.git = {
    enable = true;
    userName = "Victor Luque";
    userEmail = "luque.viictor@gmail.com";
  };

  home.packages = with pkgs; [
    # Dev tools.
    gitkraken

    # Graphics.
    krita
  ];

  # VSCode config and extensions.
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
    ];
  };

}
