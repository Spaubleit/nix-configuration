{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    devenv.url = "github:cachix/devenv";
    ags.url = "github:Aylur/ags";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    webstorm.url = "github:nixos/nixpkgs/806075be2bdde71895359ed18cb530c4d323e6f6";
  };
  outputs = inputs@{ nixpkgs, nixpkgs-stable, home-manager, devenv, ags, webstorm, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-28.3.1" ];
      };
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-webstorm = import webstorm {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./klipper.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.spaubleit = import ./home.nix { 
                config = {};
                inherit pkgs pkgs-stable pkgs-webstorm system devenv ags;
              };
            }
          ];
        };
      };
    };
}
