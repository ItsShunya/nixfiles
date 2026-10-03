{
  description = "Main config NixOS flake";

  inputs = {
    # NixOS official package source..
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Home Manager for managing user configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Encrypted secrets, decrypted on the host at activation time.
    # Pinned: later revisions need Go 1.26, which nixos-25.11 lacks.
    # Drop the rev once nixpkgs moves to 26.05.
    sops-nix = {
      url = "github:Mic92/sops-nix/13616fff713a9f94055c66f15687ebdc17a335df";
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
          specialArgs = { inherit inputs; };
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
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/server/nb250-10n/configuration.nix

            # Standalone home-manager configuration, available through
            # 'home-manager --flake .#name@hostname'.
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.shunya = import ./modules/home/users/nb250-10n/home.nix;
            }
          ];
        };
      };
    };
}
