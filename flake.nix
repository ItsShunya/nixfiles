{
  description = "Main config NixOS flake";

  inputs = {
    # NixOS official package source..
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Home Manager for managing user configuration.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Encrypted secrets, decrypted on the host at activation time.
    sops-nix = {
      url = "github:Mic92/sops-nix";
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
