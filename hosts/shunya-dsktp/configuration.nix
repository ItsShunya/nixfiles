{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../shared
    ];

  # --- USER ---

  # Define a user account.
  users.users.shunya = {
    isNormalUser = true;
    description = "Shunya";
    extraGroups = [ "networkmanager" "wheel" ];
    useDefaultShell = true;
    packages = with pkgs; [
      alacritty
      neovim
      nerdfonts
      # The following modules are for i3.
      gnome.gnome-keyring
      polkit_gnome
      clipmenu
    ];
  };

  networking.hostName = "shunya-dsktp";

  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];

  # --- SERVICES ---

  services = {

    # Window System. 
    xserver = {
      enable = true;

      # Keyboard config.
      xkb = {
        layout = "es";
        variant = "";
      };
      
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
          enableXfwm = false;
        };
      };

      # Display manager --> lightDM.
      displayManager = {
        lightdm.enable = true;
        defaultSession = "xfce+i3";
      };
    };

    # Other services.
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
  };


  # --- PROGRAMS ---

  programs = {
    thunar.enable = true;
    dconf.enable = true;  # Necessary to save some configs after reboot.
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };


  # --- BOOT ---

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
