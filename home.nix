{ config, pkgs, pkgs-stable, pkgs-jetbrains-old, devenv, system, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
      };
      bind = [
        "SUPER,t,exec,kitty"
        "SUPER,Return,exec,wofi -S run"
      ];
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
      nodejs
      yarn
      git
      unrar
      python3Full
      usbutils
      steam-run
      ventoy-bin
    
      # Apps
      firefox
      google-chrome
      pkgs-jetbrains-old.jetbrains.webstorm
      # pkgs-unstable.jetbrains.gateway
      jetbrains-toolbox
      mozillavpn
      obsidian
      libreoffice
      spotify
      protonvpn-gui
      qbittorrent
      freecad
      prusa-slicer
      cura
      printrun
      mpv
      blender
      psst
      discord
      lutris
      gnome.gnome-boxes
      dbeaver
      kitty
      
      # Messengers
      tdesktop
      teams
      slack
      zoom-us
      skypeforlinux
      
      # Graphics
      krita
      gimp
      
      # gnome
      gnome.gnome-tweaks
      gnomeExtensions.syncthing-icon
      gnomeExtensions.gtk-title-bar
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.pop-shell
      
      devenv.packages.x86_64-linux.devenv
      
      wineWowPackages.stable     
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
        mode = "dock";
        potition = "top";
        layer = "top";
        height = 40;
        margin = 6;
      };
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {};
    };
    home-manager.enable = true;
    #steam.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
      extensions = with pkgs.vscode-extensions; [
      ];
    };
  };
}
