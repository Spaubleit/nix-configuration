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
    
      # Apps
      firefox
      google-chrome
      pkgs-unstable.jetbrains.webstorm
      mozillavpn
      obsidian
      libreoffice
      spotify
      protonvpn-gui
      transmission-gtk
      
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
  };
}
