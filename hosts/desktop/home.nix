{ inputs, pkgs, pkgs-webstorm, pkgs-stable, ... }: {
  imports = [
    # inputs.ags.homeManagerModules.default
  ];
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
        # monitor switch
        "SUPER, Home, focusmonitor, -1"
        "SUPER, End, focusmonitor, +1"
        # workspace switch
        "SUPER, Prior, workspace, m-1"
        "SUPER, Next, workspace, m+1"
        "SUPER, KP_End, workspace, 1"
        "SUPER, KP_Down, workspace, 2"
        "SUPER, KP_Next, workspace, 3"
        "SUPER, KP_Left, workspace, 4"
        "SUPER, KP_Begin, workspace, 5"
        "SUPER, KP_Right, workspace, 6"
        "SUPER, KP_Home, workspace, 7"
        "SUPER, KP_Up, workspace, 8"
        "SUPER, KP_Prior, workspace, 9"
        # move to workspace
        "SUPER, Prior, movetoworkspace, m-1"
        "SUPER, Next, movetoworkspace, m+1"
        "SUPER_CTRL, KP_End, movetoworkspace, 1"
        "SUPER_CTRL, KP_Down, movetoworkspace, 2"
        "SUPER_CTRL, KP_Next, movetoworkspace, 3"
        "SUPER_CTRL, KP_Left, movetoworkspace, 4"
        "SUPER_CTRL, KP_Begin, movetoworkspace, 5"
        "SUPER_CTRL, KP_Right, movetoworkspace, 6"
        "SUPER_CTRL, KP_Home, movetoworkspace, 7"
        "SUPER_CTRL, KP_Up, movetoworkspace, 8"
        "SUPER_CTRL, KP_Prior, movetoworkspace, 9"
      ];
      monitor = [
        "DP-1,     2560x1440, 1440x580, 1"
        "HDMI-A-1, 2560x1440, 0x0,    1, transform, 1"
        # ",         preferred, auto,   1"
      ];
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
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
      wireplumber
      firefoxpwa
      deploy-rs
      nixos-anywhere

      # Apps
      google-chrome
      tor-browser
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
      dbeaver-bin
      kitty
      authenticator
      megasync
      minigalaxy
      obs-studio
      # bottles
      # (bottles-unwrapped.override { extraLibraries = pkgs: [pkgs.libunwind ]; })
      pkgs-webstorm.jetbrains.webstorm
      proton-pass
      vial

      # Messengers
      tdesktop
      slack
      zoom-us
      skypeforlinux
      wire-desktop
      mattermost-desktop

      # Graphics
      krita
      gimp

      # gnome
      gnome.gnome-tweaks
      gnomeExtensions.syncthing-indicator
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.pop-shell
      gnomeExtensions.smart-auto-move

      inputs.devenv.packages.x86_64-linux.devenv
      wineWowPackages.stable

      # libs
      libunwind # for steam in bottles
    ];

    file = {
      ".config/containers/policy.json".text = ''
        {
          "default": [{"type": "insecureAcceptAnything"}]
        }
      '';
      ".config/containers/registries.conf".text = ''
        unqualified-search-registries = [ "docker.io" ]
      '';
    };
  };

  services.syncthing = { enable = true; };

  systemd.user = {
    startServices = "sd-switch";
    services.ags = {
      Unit = { Description = "Run ags"; };
      Install = { WantedBy = [ "default.target" ]; };
      Service = {
        # todo refer home-manager environment package
        ExecStart = "${pkgs.ags}/bin/ags";
      };
    };
  };

  programs = {
    firefox = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ];
    };
    # ags = {
    #   enable = true;
    #   configDir = ./desktop/ags;
    #   extraPackages = with pkgs; [ gtksourceview webkitgtk accountsservice ];
    # };
    bash.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    wofi.enable = true;
    waybar = {
      enable = false;
      systemd.enable = true;
      settings = {
        primary = {
          mode = "dock";
          potition = "top";
          layer = "top";
          height = 40;
          margin = "6";

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "hyprland/language" ];
        };
      };
    };
    hyprlock = {
      enable = true;
      settings = {
        background = { color = "rgba(25, 20, 20, 0.5)"; };
        input-field = { size = "200,50"; };
      };
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = { };
    };
    home-manager.enable = true;
    # steam.enable = true;
    vscode = {
      enable = true;
      userSettings = {
        "window.openFoldersInNewWindow" = "on";
        "files.autoSave" = "onWindowChange";
        "workbench.colorTheme" = "Webstorm IntelliJ Darcula Theme";
      };
      extensions = with pkgs.vscode-extensions;
        [
          bbenoist.nix
          # xr0master.webstorm-intellij-darcula-theme
        ];
    };
  };
}
