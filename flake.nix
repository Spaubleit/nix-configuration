{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-jetbrains-old.url = "github:nixos/nixpkgs/d1c3fea7ecbed758168787fe4e4a3157e52bc808";
    devenv.url = "github:cachix/devenv/v0.6.2";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nixpkgs-jetbrains-old, home-manager, devenv, ... }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-jetbrains-old = import nixpkgs-jetbrains-old {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./klipper.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.spaubleit = import ./home.nix { 
                config = {};
                inherit pkgs pkgs-unstable pkgs-jetbrains-old system devenv; 
              };
            }
          ];
        };
      };
    };
}
