{
  description = "Main config NixOS flake";

  inputs = {
    # NixOS official package source..
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

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    # NixOS configuration entrypoint, available through
    # 'nixos-rebuild --flake .#name'.
    nixosConfigurations = {
      shunya-dsktp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/shunya-dsktp/configuration.nix

          {
             nix = {
                settings.experimental-features = [ "nix-command" "flakes" ];
             };
          }
          
	  # Standalone home-manager configuration, available through
          # 'home-manager --flake .#name@hostname'.
          home-manager.nixosModules.home-manager
	  {
            home-manager.useGlobalPkgs = true;
	    home-manager.useUserPackages = true;

	    home-manager.users.shunya = import ./home/shunya-dsktp/home.nix;
          }
       ];
      };
    };
  };
}
