{ config, lib, pkgs, ... }:

let
  wallpaper_src = ../../../bin/images/wallpaper;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../../modules/common
    ../../../modules/nixos/optional/bootloader/systemd
    ../../../modules/nixos/optional/network/openssh/client
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
      # The following modules are for i3.
      gnome-keyring
      polkit_gnome
      clipmenu
      lightlocker # Session-locker for XFCE workaround.
    ];
  };

  networking.hostName = "shunya-dsktp";

  fonts.packages = with pkgs; [
    font-awesome
    fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  # --- SERVICES ---

  services = {

    # Window System.
    xserver = {
      enable = true;

      # Window manager --> i3wm.
      # Configured in Home Manager profile.
      windowManager.i3 = {
        enable = true;
      };

      # Keep Xfce active (no GUI) for tools.
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableScreensaver = false;
          enableXfwm = false;
        };
      };

      # Display manager --> lightDM.
      displayManager = {
        lightdm =  {
          enable = true;
          greeter.enable = true;
          greeters.gtk.enable = false;
          greeters.mini.enable = false;
          greeters.slick = {
            enable = lib.mkForce true;
            theme.name = "Arc-Dark";   # example
            iconTheme.name = "Papirus";
            draw-user-backgrounds = false;
            extraConfig = ''
              show-hostname=true
              show-keyboard=false
              show-a11y=false
              show-power=false
              only-on-monitor=0
            '';
          };
          background = "${wallpaper_src}/flying_ships_h.jpg";
        };
      };
    };
  };

  services.displayManager.defaultSession = "xfce+i3";

  # --- PROGRAMS ---

  programs = {
    thunar.enable = true;
    dconf.enable = true; # Necessary to save some configs after reboot.
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
