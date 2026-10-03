# Colors for the places Stylix doesn't theme itself (Polybar, the i3lock
# command), by role. Home Manager modules read them through the `palette`
# argument (set in ./home.nix).
#
# Each role is a slot of the Stylix scheme, so switching schemes recolors
# these too. In base16, base00-base07 run from the darkest background to the
# lightest foreground, and base08-base0F are accents: red, orange, yellow,
# green, cyan, blue, magenta, brown.
{
  base00,
  base01,
  base03,
  base05,
  base08,
  base0A,
  base0B,
  ...
}:
{
  # Bar background (base16's status bar slot), and the focused workspace's text.
  background = base01;
  # Text, and the background of the focused workspace.
  foreground = base05;
  # Labels that stand out: network interface and mount point names.
  primary = base0A;
  # Inactive state, like a disconnected interface.
  disabled = base03;
  # Problem state, like a filesystem that isn't mounted.
  alert = base08;

  # Workspace with an urgent window; i3 borders it in the same red.
  urgent-background = base08;
  urgent-foreground = base00;

  # Volume level, and the muted label.
  volume = base0B;
  volume-muted = base03;

  # i3lock screen.
  lock = base00;
}
