# Workstation on X11: i3 inside an Xfce session, Polybar, picom, LightDM.
{
  imports = [
    ./desktop.nix
    ../modules/nixos/x11.nix
  ];

  home-manager.users.shunya.imports = [
    ../modules/home/desktop/polybar
    ../modules/home/desktop/i3.nix
    ../modules/home/desktop/picom.nix
  ];
}
