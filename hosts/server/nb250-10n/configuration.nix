{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../../modules/common
    ../../../modules/nixos/optional/bootloader/grub
    ../../../modules/nixos/optional/network/openssh/server
    #../../../modules/nixos/optional/services/dnsmasq
    # HomeLab containers.
    ../../../modules/nixos/optional/containers/home_assistant
    ../../../modules/nixos/optional/containers/fava
    ../../../modules/nixos/optional/containers/omeka_s
  ];

  # --- USER ---

  # Define a user account.
  users.users.shunya = {
    isNormalUser = true;
    description = "Shunya";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    useDefaultShell = true;
    packages = with pkgs; [
      neovim
    ];
  };

  networking.hostName = "nb250-10n";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
