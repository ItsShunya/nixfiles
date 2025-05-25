{
  description = "Main config NixOS flake";

  inputs = {
    # NixOS official package source..
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Home Manager for managing user configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    {
      # NixOS configuration entrypoint, available through
      # 'nixos-rebuild --flake .#name'.
      nixosConfigurations = {
        shunya-dsktp = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/desktop/shunya-dsktp/configuration.nix

            # Standalone home-manager configuration, available through
            # 'home-manager --flake .#name@hostname'.
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.shunya = import ./modules/home/users/shunya-dsktp/home.nix;
            }
          ];
        };

        nb250-10n = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/server/nb250-10n/configuration.nix

          ];
        };
      };
    };
}
