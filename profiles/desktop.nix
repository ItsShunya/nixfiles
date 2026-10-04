# Workstation, whatever the window manager: audio, printing, theme and the
# desktop programs. Hosts don't import it directly: they pick a window manager
# with ./desktop-niri.nix or ./desktop-i3.nix, which build on it.
{
  imports = [
    ./base.nix
    ../modules/nixos/desktop-programs.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/printing.nix
    ../themes
  ];

  home-manager.users.shunya.imports = [
    ../modules/home/desktop/alacritty
    ../modules/home/desktop/vscode.nix
    ../themes/home.nix
  ];
}
