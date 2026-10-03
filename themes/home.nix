# Look of every desktop, user side. Stylix (set up in ./default.nix) themes
# the programs it supports; this file covers the rest, and hands
# ./palette.nix to every Home Manager module as the `palette` argument.
{ config, ... }:

{
  _module.args.palette = import ./palette.nix config.lib.stylix.colors.withHashtag;

  # Themed programs; ./default.nix turns off everything not listed.
  stylix.targets = {
    alacritty.enable = true;
    gtk.enable = true;
    i3.enable = true;
    # Not vscode: its theme is an extension, and once Home Manager installs
    # any extension it rewrites extensions.json on every theme change, after
    # which VS Code deletes the extensions installed from the marketplace.
    # VS Code uses the matching "Catppuccin Mocha" theme from the marketplace.
  };

  # Polybar isn't a Stylix target: colors come from the palette, fonts from here.
  services.polybar.config."bar/main" = {
    font-0 = "${config.stylix.fonts.monospace.name}:pixelsize=9;3";
    font-1 = "Iosevka Nerd Font:pixelsize=9;2";
  };

  programs.alacritty.settings.colors.draw_bold_text_with_bright_colors = true;
}
