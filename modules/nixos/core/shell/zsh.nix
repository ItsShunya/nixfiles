{ config, pkgs, ... }:

{

  # Set Zsh as default shell.
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ 
     zsh 
  ];
  users.defaultUserShell = pkgs.zsh;

}