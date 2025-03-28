{ config, pkgs, ... }: {

  # Bootloader.
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

  security.rtkit.enable = true;

  security.pam.services.hyprlock = { };

  services = {
    pulseaudio.enable = false;
    flatpak.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    fluidd.enable = true;
  };

  # xdg.portal = {
  #   enable = true;
    # extraPortals = with pkgs; [ 
    #   xdg-desktop-portal-gtk 
    # ];
  # };

  services.udev.packages = with pkgs; [ vial ];

  # start of unknown territory
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice 
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  # end of unknown territory

  virtualisation = {
    containers.registries.search = [ "docker.io" ];
    docker = { enable = true; };
    podman = {
      enable = true;
      # dockerCompat = true;
      # dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.spaubleit = {
      isNormalUser = true;
      description = "spaubleit";
      extraGroups =
        [ "networkmanager" "wheel" "podman" "docker" "scanner" "lp" "libvirtd" ];
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

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      package = with pkgs; steam.override {
        extraPkgs = pkgs: [
          jq
          cabextract
          wget
          # fortivpn
          iproute2
          ppp
        ];
      };
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
