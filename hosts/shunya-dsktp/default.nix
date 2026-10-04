{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Niri (Wayland). For i3 (X11) instead, import ../../profiles/desktop-i3.nix:
    # home.nix keeps the settings for both.
    ../../profiles/desktop-niri.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };

  # Login screen on the main monitor only. Appended to the greeter's niri
  # config from modules/nixos/niri.nix.
  environment.etc."greetd/niri.kdl".text = ''
    output "DP-2" {
        off
    }
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # NOTE: Only update it on clean installs.
  system.stateVersion = "25.11"; # Did you read the comment?
}
