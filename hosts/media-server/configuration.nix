{ config, pkgs, ... }: {
  networking = {
    hostName = "media-server";
    networkmanager.enable = true;
  };

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [ curl git ];
  services = {
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  users.users = {
    spaubleit = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword =
        "$y$j9T$z.JT2f3VWNsXMHupujeRI/$UBK0na3NcstexOdQfRrXqt6uQlfXujsF1E3uGgDic46";
      packages = with pkgs; [ stremio firefox jellyfin-media-player transmission ];
    };
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjzIxkq7kdjaTfHXwwNmKvdm7k+OvJa/gVyNrvtqD1P main desktop"
    ];
  };

  services.jellyfin = {
    enable = true;
  };

  system.stateVersion = "24.05";
}
