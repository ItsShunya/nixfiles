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

    # One color scheme and set of fonts applied to every desktop program.
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      # A host is hosts/<name>/default.nix (system) plus
      # hosts/<name>/home.nix (Home Manager, user shunya).
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            {
              networking.hostName = name;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.shunya.imports = [ ./hosts/${name}/home.nix ];
              };
            }
          ];
        };
    in
    {
      # NixOS configuration entrypoint, available through
      # 'nixos-rebuild --flake .#name'.
      nixosConfigurations = nixpkgs.lib.genAttrs [
        "shunya-dsktp"
        "nb250-10n"
      ] mkHost;
    };
}
