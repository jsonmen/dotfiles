{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, nixvim, home-manager, ... }@inputs: {
  nixosConfigurations.jsonmen = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/jsonmen/configuration.nix # Your main system configuration file
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
