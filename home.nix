{ config, pkgs, pkgs-unstable, devenv, system, ... }:
{
  home = {
    username = "spaubleit";
    homeDirectory = "/home/spaubleit";
    stateVersion = "22.05";
    
    packages = with pkgs; [
      # Utils
      cloc
      nodejs
      yarn
      git
      unrar
      python3Full
      usbutils
    
      # Apps
      firefox
      pkgs-unstable.google-chrome
      pkgs-unstable.jetbrains.webstorm
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
      
      # Messengers
      tdesktop
      pkgs-unstable.teams
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
      
      wine      
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
