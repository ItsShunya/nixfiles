{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "xrender";
    fade = true;
    fadeDelta = 5;
    opacityRules = [
      "99:fullscreen"
      "91:class_g = 'Alacritty' && focused"
      "81:class_g = 'Alacritty' && !focused"
    ];

    shadow = true;
    shadowOpacity = 0.75;

    settings = {
      corner-radius = 0;
    };
  };

  xsession.windowManager.i3.config.startup = [
    {
      command = "systemctl --user restart picom";
      always = true;
      notification = false;
    }
  ];
}
