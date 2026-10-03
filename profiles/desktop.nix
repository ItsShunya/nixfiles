# Workstation: X11 session with i3, plus the desktop user programs.
{
  imports = [
    ./base.nix
    ../modules/nixos/x11.nix
  ];

  home-manager.users.shunya.imports = [
    ../modules/home/desktop/polybar
    ../modules/home/desktop/i3.nix
    ../modules/home/desktop/alacritty
    ../modules/home/desktop/picom.nix
    ../modules/home/desktop/vscode.nix
  ];
}
