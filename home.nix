{ config, pkgs, pkgs-stable, devenv, system, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      input = {
        kb_layout = "us,ru";
        kb_variant = "dvp,typewriter";
        kb_options = "grp:caps_toggle";
        numlock_by_default = true;
      };
      bind = [
        "SUPER,Return,exec,wofi -S run"
        "SUPER,q,killactive"
        "SUPER,t,exec,kitty"
        "SUPER,l,exec,hyprlock"
        # focus
        "SUPER,up,movefocus,u"
        "SUPER,down,movefocus,d"
        "SUPER,left,movefocus,l"
        "SUPER,right,movefocus,r"
        # movement
        "SUPER_CTRL,up,movewindow,u"
        "SUPER_CTRL,down,movewindow,d"
        "SUPER_CTRL,left,movewindow,l"
        "SUPER_CTRL,right,movewindow,r"
      ];
      monitor = [
        "DP-1,     2560x1440, 1440x560, 1"
        "HDMI-A-1, 2560x1440, 0x0,    1, transform, 1"
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
      slack
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
      gnomeExtensions.syncthing-indicator
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
    hyprlock = {
      enable = true;
      settings = {
        background = {
          color = "rgba(25, 20, 20, 0.5)";
        };
        input-field = {
          size = "200,50";
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
