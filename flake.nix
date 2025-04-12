{
  description = "Main config NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.shunya-dsktp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect.
        ./configuration.nix
        {
           nix = {
              settings.experimental-features = [ "nix-command" "flakes" ];
           };
        }
      ];
    };
  };
}
