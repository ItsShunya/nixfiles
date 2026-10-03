{ config, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    # One encrypted file per host: secrets/<hostname>.yaml.
    # Recipients for each file are listed in /.sops.yaml.
    defaultSopsFile = ./. + "/${config.networking.hostName}.yaml";

    # Decrypt with the host's SSH key; no separate age key to deploy.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
