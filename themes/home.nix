# Look of every desktop, user side: fonts and color themes of the programs.
# Colors set inside a program's own module come from ./palette.nix, which
# this file hands to every Home Manager module as the `palette` argument.
{ pkgs, ... }:

{
  _module.args.palette = import ./palette.nix;

  xsession.windowManager.i3.config.fonts = {
    names = [
      "DejaVu Sans Mono"
      "FontAwesome 6"
    ];
    size = 11.0;
  };

  services.polybar.config."bar/main" = {
    font-0 = "FantasqueSansMono:pixelsize=9;3";
    font-1 = "Iosevka:pixelsize=9;2";
  };

  # Terminal colors and font; alacritty.toml imports this file.
  home.file.".config/alacritty/theme.toml".source = ./alacritty.toml;

  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    dracula-theme.theme-dracula
  ];
}
