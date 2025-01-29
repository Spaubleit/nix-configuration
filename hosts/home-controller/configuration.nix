{ config, pkgs, ... }: {
    networking = {
        hostName = "home-controller";
        networkmanager.enable = true;
    };

    services = {
        openssh.enable = true;
        pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
        };
        xserver = {
            enable = true;
            desktopManager.gnome.enable = true;
            displayManager.gdm = {
                enable = true;
                wayland = true;
            };
        };
    };

    users.users = {
        spaubleit = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            hashedPassword =
                "$y$j9T$z.JT2f3VWNsXMHupujeRI/$UBK0na3NcstexOdQfRrXqt6uQlfXujsF1E3uGgDic46";
        };
        root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjzIxkq7kdjaTfHXwwNmKvdm7k+OvJa/gVyNrvtqD1P main desktop"
        ];
    };

    system.stateVersion = "24.11";
}