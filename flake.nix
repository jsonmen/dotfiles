{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.jsonmen = nixpkgs.lib.nixosSystem {
      modules = [
        { nix.settings.experimental-features = ["nix-command" "flakes"]; }
        ./configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
