{ config, pkgs, ... }:

{

  # Keyboard config.
  services.xserver.xkb  = {
    layout = "es";
    variant = "";
  };

  # Configure console keymap.
  console.keyMap = "es";

}

