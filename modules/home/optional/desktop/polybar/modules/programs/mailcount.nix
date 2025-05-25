{ config, pkgs, ... }:
{
  services = {
    polybar = {
      config = {
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
      };
    };
  };
}