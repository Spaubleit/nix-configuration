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
  outputs = inputs@{ self, deploy-rs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-28.3.1" "yandex-browser-stable-24.4.1.951-1" ];
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
        # desktop = inputs.nixpkgs.lib.nixosSystem {
        #   inherit system pkgs;
        #   specialArgs = { inherit inputs pkgs-stable pkgs-webstorm; };
        #   modules = [
        #     inputs.nur.nixosModules.nur
        #     ./configuration.nix
        #     ./hosts/desktop/klipper.nix
        #     inputs.home-manager.nixosModules.home-manager
        #     {
        #       home-manager.extraSpecialArgs = { inherit inputs pkgs-stable pkgs-webstorm; };
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.backupFileExtension = "backup";
        #       home-manager.sharedModules = [ inputs.nur.hmModules.nur ];
        #       home-manager.users.spaubleit.imports = [ ./hosts/desktop/home.nix ];
        #       # home-manager.users.spaubleit = import ./hosts/desktop/home.nix {
        #       #   inherit inputs pkgs pkgs-stable pkgs-webstorm;
        #       # };
        #     }
        #   ];
        # };
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
