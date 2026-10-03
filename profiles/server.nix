# Headless machine reached over SSH.
{
  imports = [
    ./base.nix
    ../modules/nixos/ssh.nix
  ];
}
