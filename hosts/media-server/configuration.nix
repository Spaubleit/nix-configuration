{ config, pkgs, ... }: {
    imports = [
        ./disks.nix
        ./hardware-configuration.nix
    ];
    
    boot.loader.systemd-boot.enable = true;
    
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    networking = {
        hostName = "media-server";
        networkmanager.enable = true;
    };
    
    services.openssh.enable = true;
    
    environment.systemPackages = with pkgs; [
        curl
        git
    ];
    
    users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjzIxkq7kdjaTfHXwwNmKvdm7k+OvJa/gVyNrvtqD1P main desktop"
    ];
    
    system.stateVersion = "24.05";
}