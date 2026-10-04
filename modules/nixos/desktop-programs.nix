{
  # Programs every desktop gets, whatever its window manager.

  # --- PROGRAMS ---

  programs = {
    firefox.enable = true;
    thunar.enable = true;
    dconf.enable = true; # Necessary to save some configs after reboot.
  };

  # Thunar's trash, removable drives (gvfs, with udisks2) and thumbnails.
  services = {
    gvfs.enable = true;
    tumbler.enable = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
}
