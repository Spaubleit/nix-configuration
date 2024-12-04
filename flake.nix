{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
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
      "github:nixos/nixpkgs/6b5019a48f876f3288efc626fa8b70ad0c64eb46";
  };
  outputs = inputs@{ self, deploy-rs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ 
          "electron-28.3.1" 
          "wire-desktop-3.36.3462"
          "yandex-browser-stable-24.4.1.951-1" 
        ];
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-webstorm = import inputs.webstorm {
        inherit system;
        config.allowUnfree = true;
      };
      createSystem = modules: inputs.nixpkgs.lib.nixosSystem {
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
        desktop = createSystem [
          ./modules/common.nix
          ./hardware/desktop.nix
          ./hosts/desktop/default.nix
        ];
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
