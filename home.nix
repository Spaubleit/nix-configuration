{ config, pkgs, pkgs-stable, devenv, system, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      input = {
        kb_layout = "us";
        kb_variant = "dvp";
      };
      bind = [
        "SUPER,t,exec,kitty"
        "SUPER,Return,exec,wofi -S run"
      ];
      monitor = [
        "DP-1,     2560x1440, 2560x0, 1"
        "HDMI-A-1, 2560x1440, 0x0,    1"
        # ",         preferred, auto,   1"
      ];
      # workspace = [
      #   "1,rounding:false"
      #   "2,rounding:false"
      # ];
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  home = {
    username = "spaubleit";
    homeDirectory = "/home/spaubleit";
    stateVersion = "23.05";

    # sessionVariables = {
    #   NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
    # };
    
    packages = with pkgs; [
      # Utils
      cloc
      yarn
      git
      unrar
      python3Full
      usbutils
      steam-run
      ventoy-full
      podman-compose
      devbox
      nix-direnv
      i2p
    
      # Apps
      firefox
      google-chrome
      # pkgs-unstable.jetbrains.gateway
      jetbrains-toolbox
      mozillavpn
      obsidian
      libreoffice
      spotify
      protonvpn-gui
      qbittorrent
      freecad
      gmsh # for freecad
      calculix # for freecad
      prusa-slicer
      printrun
      mpv
      blender
      psst
      discord
      lutris
      gnome.gnome-boxes
      dbeaver
      kitty
      authenticator
      megasync
      minigalaxy
      # bottles
      # (bottles-unwrapped.override { extraLibraries = pkgs: [pkgs.libunwind ]; })
      
      # Messengers
      tdesktop
      slack
      zoom-us
      skypeforlinux
      wire-desktop
      
      # Graphics
      krita
      gimp
      
      # gnome
      gnome.gnome-tweaks
      gnomeExtensions.syncthing-icon
      gnomeExtensions.gtk-title-bar
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.pop-shell
      gnomeExtensions.smart-auto-move
      
      devenv.packages.x86_64-linux.devenv
      wineWowPackages.stable     

      # libs
      libunwind # for steam in bottles
    ];
  };
  
  services.syncthing = {
    enable = true;
  };
  
  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    wofi.enable = true;
    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        primary = {
          mode = "dock";
          potition = "top";
          layer = "top";
          height = 40;
          margin = "6";

          modules-left = ["hyprland/workspaces"];
          modules-center = ["clock"];
        };
      };
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {};
    };
    home-manager.enable = true;
    # steam.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
      extensions = with pkgs.vscode-extensions; [
      ];
    };
  };
}
