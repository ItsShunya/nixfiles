{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PubKeyAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.ssh.startAgent = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    config.services.home-assistant.config.http.server_port
    53
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];

}
