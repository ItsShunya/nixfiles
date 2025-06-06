{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../../modules/common
    ../../../modules/nixos/optional/bootloader/grub
    ../../../modules/nixos/optional/network/openssh/server
    ../../../modules/nixos/optional/services/home_assistant
    ../../../modules/nixos/optional/services/dnsmasq
  ];

  # --- USER ---

  # Define a user account.
  users.users.shunya = {
    isNormalUser = true;
    description = "Shunya";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    useDefaultShell = true;
    packages = with pkgs; [
      neovim
    ];
  };

  networking.hostName = "nb250-10n";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "es";
    variant = "";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
