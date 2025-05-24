{ pkgs, ... }:
{
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybar.override {
        pulseSupport = true;
        githubSupport = true;
        i3Support = true;
      };
      script = "polybar &";
      config = {
        "bar/main" = {
          bottom = false;
          font-0 = "FantasqueSansMNerdFont Propo:pixelsize=9;3";
          font-1 = "Iosevka Nerd Font:pixelsize=9;2";
          width = "100%";
          height = "12pt";
          radius = 0;
          background = "#3D0F34"; #base01
          foreground = "#E5E9F0"; # base 05
          line-size = "3pt";
          border-top-size = 0;
          border-right-size = 0;
          border-left-size = 0;
          border-bottom-size = "4pt";
          border-color = "#3D0F34"; # base 00
          padding-left = 0;
          padding-right = 1;
          module-margin = 1;
          modules-left = "power date i3";
          modules-center = "xwindow";
          modules-right = "memory cpu eth pulseaudio hostname uname";
          enable-ipc = true;
          separator = "|";
          #tray-position = "right";
          #wm-restack = "i3";
          #override-redirect = true;
        };
        "module/i3" = {
          type = "internal/i3";
          # pin-workspaces = true;
          show-urgent = true;
          strip-wsnumbers = true;
          index-sort = true;
          enable-click = true;
          wrapping-scroll = true;
          fuzzy-match = true;
          format = "<label-state> <label-mode>";
          label-focused = "%name%";
          label-focused-foreground = "#3D0F34"; #base01
          label-focused-background = "#E5E9F0"; # base 05
          label-focused-padding = 1;
          label-unfocused = "%name%";
          label-unfocused-padding = 1;
          label-visible = "%name%";
          label-visible-padding = 1;
          label-urgent = "%name%";
          label-urgent-foreground = "#2E3440"; # base 00
          label-urgent-background = "#88C0D0"; #base 08
          label-urgent-padding = 1;
        };
        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:60:...%";
        };
        # "module/filesystem" = {
        # type = "internal/fs";
        # interval = 25;
        # mount-0 = "/";
        # label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%";
        # label-unmounted = "%mountpoint% not mounted";
        # label-unmounted-foreground = colors.disabled;
        # };
        "module/mailcount" = {
          type = "custom/script";
          interval = 10;
          format = "<label>";
          exec = builtins.toString (pkgs.writeShellScript "mailcount.sh" ''
            ${pkgs.notmuch}/bin/notmuch new > /dev/null
            UNREAD=$(${pkgs.notmuch}/bin/notmuch count is:inbox and is:unread and folder:main/Inbox)
            if [ $UNREAD = "0" ]; then
              echo ""
            else
              echo "%{T2}%{T-} $UNREAD "
            fi
          '');
          click-left =
            "i3-msg 'exec --no-startup-id kitty --class aerc aerc'; sleep 0.15; i3-msg '[class=aerc] focus'";
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          format-volume = "<ramp-volume> <label-volume>";
          format-volume-foreground = "#BF616A"; # base 0B
          label-volume = "%percentage%%";
          label-muted = "󰝟 ---";
          label-muted-foreground = "#4C566A"; #base 03
          ramp-volume-0 = "";
          ramp-volume-1 = "󰕾";
          ramp-volume-2 = "";
          # click-right = config.audioSwitchCommand;
        };
        # "module/xkeyboard" = {
        # type = "internal/xkeyboard";
        # blacklist-0 = "num lock";
        # label-layout = "%layout%";
        # label-layout-foreground = colors.primary;
        # label-indicator-padding = 2;
        # label-indicator-margin = 1;
        # label-indicator-foreground = colors.background;
        # label-indicator-background = colors.secondary;
        # };
        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = "RAM ";
          format-prefix-foreground = "#E5E9F0"; #base06
          label = "%percentage_used:2%%";
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format-prefix = "CPU ";
          format-prefix-foreground = "#E5E9F0";
          label = "%percentage:2%%";
        };
        "network-base" = {
          type = "internal/network";
          interval = 5;
          format-connected = "<label-connected>";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
        };
        # "module/wlan" = {
        # "inherit" = "network-base";
        # interface-type = "wireless";
        # label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
        # };
        "module/eth" = {
          "inherit" = "network-base";
          interface-type = "wired";
          label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
        };
        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%d %b %l:%M %p";
          date-alt = "%Y-%m-%d %H:%M:%S";
          label = "%date%";
          label-foreground = "#E5E9F0"; #base0A;
          # format-background = "#3D0F34";
        };
        "module/power" = {
          type = "custom/text";
          content = "  ";
          #click-left = config.powerCommand;
          content-foreground = "#E5E9F0"; #base04
        };
        "module/whoami" = {
          type = "custom/script";
          exec = "whoami";
          interval = 0;
          format = "<label>";
          format-foreground = "#E5E9F0";
          format-background = "#3D0F34";
        };
        "module/uname" = {
          type = "custom/script";
          exec = "echo $(uname) $(uname -r | tr - . | cut -d. -f1-2)";
          interval = 0;
          format = "<label>";
          format-foreground = "#E5E9F0";
          format-background = "#3D0F34";
        };
        "module/hostname" = {
          type = "custom/script";
          exec = "cat /etc/hostname";
          interval = 0;
          format = "<label>";
          format-foreground = "#E5E9F0";
          format-background = "#3D0F34";
        };
        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = false;
        };
      };
    };
  };

  xsession.windowManager.i3.config.startup = [{
    command = "pkill polybar; polybar -r main";
    always = true;
    notification = false;
  }];
}