{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    devenv.url = "github:cachix/devenv";
    ags.url = "github:Aylur/ags";
    deploy-rs.url = "github:serokell/deploy-rs";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    webstorm.url =
      "github:nixos/nixpkgs/806075be2bdde71895359ed18cb530c4d323e6f6";
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, disko, devenv
    , ags, webstorm, deploy-rs, ... }:
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
      createSystem = modules: nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = { inherit inputs pkgs pkgs-stable pkgs-webstorm; };
      };
    in {
      nixosConfigurations = {
        media-server = createSystem [
          ./modules/common.nix
          ./hardware/dell-laptop.nix
          ./hosts/media-server/default.nix
        ];
        # desktop-unstable = createSystem [
        #   ./modules/common.nix
        #   ./hardware/desktop.nix
        #   ./hosts/desktop/default.nix
        # ];
        desktop = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = { inherit inputs pkgs-stable pkgs-webstorm; };
          modules = [
            inputs.nur.nixosModules.nur
            ./configuration.nix
            ./hosts/desktop/klipper.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.spaubleit = import ./hosts/desktop/home.nix {
                inherit inputs pkgs pkgs-stable pkgs-webstorm;
              };
            }
          ];
        };
      };
      deploy.nodes.media-server = {
        hostname = "media-server.local";
        sshUser = "root";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.media-server;
        };
      };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
