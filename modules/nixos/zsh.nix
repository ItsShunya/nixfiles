{ pkgs, ... }:

{
  # Set Zsh as default shell.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
