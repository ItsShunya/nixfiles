{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon. Key-based login only; port 22 is opened
  # by `services.openssh.openFirewall` (default true).
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Without at least one key here, key-only login locks you out.
  users.users.shunya.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF90LtW/Ah9zYKSOheApuXVoQ1JWDR2Nc0VIKq9QcAD9 luque.viictor@gmail.com" # shunya-dsktp
  ];

  programs.ssh.startAgent = true;
}
