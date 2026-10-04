# Look of every desktop, system side. Stylix applies one color scheme and
# one set of fonts to every program it supports (i3, GTK, Alacritty, the
# console, the login screen…), and sets up its Home Manager half from these
# same settings. User-side tweaks are in ./home.nix.
{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;

    # List the available schemes with:
    #   ls $(nix build --no-link --print-out-paths nixpkgs#base16-schemes)/share/themes
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";

    # Login screen background. Desktop wallpapers are set per host.
    image = ../assets/wallpaper/flying_ships_h.jpg;

    fonts = {
      monospace = {
        package = pkgs.fantasque-sans-mono;
        name = "Fantasque Sans Mono";
      };
      # Alacritty's default size.
      sizes.terminal = 11.25;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    # Only the targets listed here and in ./home.nix are themed. Left on, Stylix
    # also themes programs we don't run (GNOME, KDE, Blender…), and flake
    # updates could switch on new ones. feh stays off: each host sets its own
    # wallpaper per monitor, in hosts/<name>/home.nix.
    autoEnable = false;
    targets = {
      console.enable = true;
      font-packages.enable = true;
      fontconfig.enable = true;
      gtk.enable = true;
      # Login screen: LightDM on i3 desktops, ReGreet on niri ones.
      lightdm.enable = true;
      regreet.enable = true;
    };
  };

  # Fonts beyond Stylix's own; Polybar takes its icons from Iosevka Nerd Font.
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  # Stylix only sets the greeter's background, so give its widgets the same
  # GTK and icon themes Stylix gives user programs.
  services.xserver.displayManager.lightdm.greeters.slick = {
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      inherit (config.stylix.icons) package;
      name = config.stylix.icons.dark;
    };
    draw-user-backgrounds = false;
  };
}
