{ inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    ./configuration.nix
    ./disks.nix
  ];
}
