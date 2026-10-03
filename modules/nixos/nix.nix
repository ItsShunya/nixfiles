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
    };

    # Perform garbage collection weekly to maintain low disk usage.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    # Deduplicate identical files in the store weekly.
    optimise.automatic = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

}
