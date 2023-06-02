{ config, pkgs, pkgs-unstable, pkgs-jetbrains-old, devenv, system, ... }:
{
  home = {
    username = "spaubleit";
    homeDirectory = "/home/spaubleit";
    stateVersion = "22.05";

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
      pkgs-unstable.google-chrome
      pkgs-jetbrains-old.jetbrains.webstorm
      # pkgs-unstable.jetbrains.gateway
      pkgs-unstable.jetbrains-toolbox
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
