{ inputs, ... }: {
  imports = [
    ./configuration.nix
    ./klipper.nix
    inputs.home-manager.nixosModules.default
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.spaubleit = import ./home.nix;
    }
  ];
}
