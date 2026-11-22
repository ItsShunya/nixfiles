{ config, ... }:

{
  imports = [ ./common.nix ];

  sops.secrets = {
    "wa_bridge/api_token" = { };
    # The group's exact name (not case-sensitive), for the "status" replies.
    "wa_bridge/allowed_groups" = { };
  };

  sops.templates."wa-bridge.env" = {
    content = ''
      API_TOKEN=${config.sops.placeholder."wa_bridge/api_token"}
      ALLOWED_GROUPS=${config.sops.placeholder."wa_bridge/allowed_groups"}
    '';
    restartUnits = [ "docker-wa-bridge.service" ];
  };

  virtualisation.oci-containers.containers."wa-bridge" = {
    autoStart = true;
    # v3.1.1, keep in sync with custom_components/wa_bridge in hass-config.
    image = "ghcr.io/raulpetruta/ha-wa-bridge:sha-385122d";
    # Localhost only, Home Assistant is on the host network.
    ports = [ "127.0.0.1:3000:3000" ];
    volumes = [ "wa-bridge:/usr/src/app/.wwebjs_auth" ];
    environment = {
      TZ = "Europe/Paris";
      # Only messages from the ALLOWED_GROUPS group reach Home Assistant.
      INCOMING_MESSAGES_MODE = "groups_only";
      INCOMING_MESSAGE_LOG_LEVEL = "COMPACT";
    };
    environmentFiles = [ config.sops.templates."wa-bridge.env".path ];
  };
}
