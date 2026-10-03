# Workstation: X11 session with i3, audio, printing and desktop programs.
{
  imports = [
    ./base.nix
    ../modules/nixos/x11.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/printing.nix
  ];

  home-manager.users.shunya.imports = [
    ../modules/home/desktop/polybar
    ../modules/home/desktop/i3.nix
    ../modules/home/desktop/alacritty
    ../modules/home/desktop/picom.nix
    ../modules/home/desktop/vscode.nix
  ];
}
