{
  description = "Main config NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home Manager for managing user configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      shunya-dsktp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix

          {
             nix = {
                settings.experimental-features = [ "nix-command" "flakes" ];
             };
          }

          # Make home-manager a module of nixos, so that its configuration
          # configuration will be deployed automatically when rebuilding nixos.
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.shunya = import ./home/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };
  };
}
