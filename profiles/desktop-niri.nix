# Workstation on Wayland: the niri compositor, Waybar, ReGreet.
{
  imports = [
    ./desktop.nix
    ../modules/nixos/niri.nix
  ];

  home-manager.users.shunya.imports = [
    ../modules/home/desktop/niri.nix
    ../modules/home/desktop/waybar.nix
  ];
}
