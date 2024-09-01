{ config, pkgs, ... }: {

  # Bootloader.
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.supportedFilesystems = [ "ntfs" ];

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver ];
  };
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  security.pam.services.hyprlock = { };

  services = {
    flatpak.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    moonraker.enable = true;
    fluidd.enable = true;
  };

  services.udev.packages = with pkgs; [ vial ];

  programs.dconf.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    virtualbox = {
      host.enable = true;
      host.enableExtensionPack = true;
    };
    containers.registries.search = [ "docker.io" ];
    docker = { enable = true; };
    podman = {
      enable = true;
      # dockerCompat = true;
      # dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # enable flakes
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 1m";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraGroups.vboxusers.members = [ "spaubleit" ];
    users.spaubleit = {
      isNormalUser = true;
      description = "spaubleit";
      extraGroups =
        [ "networkmanager" "wheel" "podman" "docker" "scanner" "lp" ];
      subUidRanges = [{
        count = 165536;
        startUid = 10000;
      }];
      subGidRanges = [{
        count = 165536;
        startGid = 10000;
      }];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #  wget
      virt-manager
    ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    nix-ld.enable = true;
    hyprland = {
      enable = true;
      xwayland = { enable = true; };
    };
  };
  # List services that you want to enable:

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 8384 2200 ];
      allowedUDPPorts = [ 2200 21027 ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
