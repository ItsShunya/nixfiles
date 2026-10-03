# Every color the desktop uses, by role. Home Manager modules read these
# through the `palette` argument (set in ./home.nix), so changing a value
# here recolors every place that uses it. The terminal has its own full
# color scheme in ./alacritty.toml.
{
  # Bar background, and the text of the focused workspace.
  background = "#3D0F34";
  # Text, and the background of the focused workspace.
  foreground = "#E5E9F0";
  # Labels that stand out: network interface and mount point names.
  primary = "#F0C674";
  # Inactive state, like a disconnected interface.
  disabled = "#707880";
  # Problem state, like a filesystem that isn't mounted.
  alert = "#FFFFFF";

  # Workspace with an urgent window.
  urgent-background = "#88C0D0";
  urgent-foreground = "#2E3440";

  # Volume level, and the muted label.
  volume = "#BF616A";
  volume-muted = "#4C566A";

  # i3lock screen.
  lock = "#222222";
}
