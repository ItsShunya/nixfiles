{ config, pkgs, ... }:

{
  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };

  # Packages that should be installed to all user profiles.
  home.packages = with pkgs; [

    # Command line tools.
    neofetch

    # Archives.
    zip
    unzip
    xz

    # Networking.
    mtr       		# Network diagnostic tool.
    dnsutils  		# `dig` + `nslookup`.
    nmap      		# Utility for network discovery and security auditing.
    ipcalc    		# Calculator for the IPv4/v6 addresses.

    # Misc.
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # Nix.
    nix-output-monitor 	# `nom` works like `nix` with more detailed output.

    # Productivity
    glow 		# Markdown previewer in terminal.

    # System call monitoring.
    strace 		# System call monitoring.
    ltrace 		# Library call monitoring.
    lsof 		# List open files.

    # System tools.
    sysstat
    ethtool
    pciutils 		# `lspci`
    usbutils 		# `lsusb`
  ];

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # Set some aliases.
    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
