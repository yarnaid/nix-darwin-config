{
  description = "Darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, stylix }:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#EPGETBIW0286
    darwinConfigurations."EPGETBIW0286" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./configuration.nix
        home-manager.darwinModules.home-manager
        stylix.darwinModules.stylix
      ];
    };
    darwinConfigurations."mpb-14-aum" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./configuration.nix
        home-manager.darwinModules.home-manager
        stylix.darwinModules.stylix
      ];
    };
  };
}
