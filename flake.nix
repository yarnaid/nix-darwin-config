{
  description = "Example nix-darwin system flake";

  inputs = {
    # Pinned to the 26.05 stable release (darwin channel: tested + binary-cached
    # for aarch64-darwin). Was nixpkgs-unstable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Second channel: the broader NixOS 26.05 set, for packages absent from the
    # darwin-tested channel. Exposed to all modules as `pkgs-nixos`.
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # stylix has no 26.05 release branch; track master but follow our pinned
    # nixpkgs to avoid pulling a second (unstable) nixpkgs into the closure.
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-nixos,
      home-manager,
      stylix,
    }:
    let
      system = "aarch64-darwin";
      # Instantiated NixOS-channel package set, passed to every module (nix-darwin
      # and home-manager) as `pkgs-nixos`. Use it for packages missing from the
      # darwin channel: e.g. `pkgs-nixos.somePkg`.
      pkgs-nixos = import nixpkgs-nixos {
        inherit system;
        config.allowUnfree = true;
      };
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = system;
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#EPGETBIW0286
      darwinConfigurations."EPGETBIW0286" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit pkgs-nixos; };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          stylix.darwinModules.stylix
        ];
      };
      darwinConfigurations."mpb-14-aum" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit pkgs-nixos; };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          stylix.darwinModules.stylix
        ];
      };
    };
}
