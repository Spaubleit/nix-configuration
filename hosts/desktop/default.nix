{ system, inputs, pkgs-stable, pkgs-webstorm, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    ./configuration.nix
    ./disks.nix
    ./klipper.nix
    inputs.nur.modules.nixos.default
    inputs.home-manager.nixosModules.default
    {
      home-manager.extraSpecialArgs = { inherit inputs pkgs-stable pkgs-webstorm; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.sharedModules = [ inputs.nur.modules.homeManager.default ];
      home-manager.users.spaubleit.imports = [ ./home.nix ];
    }
  ];
}
