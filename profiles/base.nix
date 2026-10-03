# Every host: Nix settings, locale, shell, the shunya user, base CLI.
{
  imports = [
    ../modules/nixos/nix.nix
    ../modules/nixos/locale.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/zsh.nix
    ../modules/nixos/user.nix
    ../modules/nixos/packages.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/printing.nix
  ];

  home-manager.users.shunya.imports = [
    ../modules/home/base.nix
    ../modules/home/git.nix
  ];
}
