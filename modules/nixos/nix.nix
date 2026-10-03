{ config, pkgs, ... }:

{

  nix = {

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ]; # Enable flakes.
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;

      # Optimize storage.
      # You can also manually optimize the store via:
      #    nix-store --optimise
      # Refer to the following link for more details:
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
      auto-optimise-store = true;
    };

    # Perform garbage collection weekly to maintain low disk usage.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    optimise.automatic = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system = {
    # Avoid symlink of configuration.nix.
    copySystemConfiguration = false;
  };

}
