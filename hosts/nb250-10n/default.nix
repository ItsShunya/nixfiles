{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../profiles/server.nix
    ../../secrets
    # HomeLab containers.
    ../../modules/nixos/homelab/home-assistant.nix
    ../../modules/nixos/homelab/fava.nix
    ../../modules/nixos/homelab/omeka.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # NOTE: Only update it on clean installs.
  system.stateVersion = "25.11"; # Did you read the comment?
}
