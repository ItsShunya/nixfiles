{ config, pkgs, ... }:

{
  imports = [
    ../shared
    ./i3wm/i3wm.nix
  ];

  # --- USER ---

  # Home-manager user details.
  home.username = "shunya";
  home.homeDirectory = "/home/shunya";

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };


  # --- PACKAGES ---

  home.packages = with pkgs; [
    # Dev tools.
    gitkraken

    # Graphics.
    krita
  ];


  # --- PROGRAMS ---

  # Basic configuration of git.
  programs.git = {
    enable = true;
    userName = "Victor Luque";
    userEmail = "luque.viictor@gmail.com";
  };

  # VSCode config and extensions.
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
    ];
  };

}
