{ config, pkgs, ... }:
{

  imports = [
    ./config.nix
    ./bars/main.nix
    ./modules/custom/hostname.nix
    ./modules/custom/uname.nix
    ./modules/interface/date.nix
    ./modules/interface/i3wm.nix
    ./modules/network/eth.nix
    ./modules/programs/pulseaudio.nix
    ./modules/system/cpu.nix
    ./modules/system/memory.nix
    ./modules/system/power.nix
  ];

  services = {
    polybar = {
      enable = true;
      script = "polybar &";
    };
  };

  xsession.windowManager.i3.config.startup = [
    {
      command = "pkill polybar; polybar -r main";
      always = true;
      notification = false;
    }
  ];
}
