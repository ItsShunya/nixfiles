{ config, pkgs, ... }:

{
  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # --- PACKAGES ---

  # Packages that should be installed to all user profiles.
  home.packages = with pkgs; [

    # Command line tools.
    fastfetch

    # Archives.
    zip
    unzip
    xz

    # Networking.
    mtr # Network diagnostic tool.
    dnsutils # `dig` + `nslookup`.
    nmap # Utility for network discovery and security auditing.
    ipcalc # Calculator for the IPv4/v6 addresses.
    inetutils # e.g. ifconfig

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
    nix-output-monitor # `nom` works like `nix` with more detailed output.

    # Productivity
    glow # Markdown previewer in terminal.

    # System call monitoring.
    strace # System call monitoring.
    ltrace # Library call monitoring.
    lsof # List open files.

    # System tools.
    sysstat
    ethtool
    pciutils # `lspci`
    usbutils # `lsusb`
  ];

  # --- PROGRAMS ---

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
}
