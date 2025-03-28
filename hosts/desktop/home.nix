{ inputs, pkgs, pkgs-stable, ... }: {
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
      nodejs
      corepack
      distrobox
      # unrar
      # python3Full
      # usbutils
      # steam-run
      ventoy-full
      # podman-compose
      # devbox
      # nix-direnv
      # i2p
      # wireplumber
      firefoxpwa
      deploy-rs
      nixos-anywhere
      p7zip

      # Apps
      google-chrome
      # tor-browser
      # yandex-browser download failure
      obsidian
      libreoffice
      spotify
      protonvpn-gui
      qbittorrent
      freecad
      prusa-slicer
      mpv
      # blender
      # psst
      # lutris
      gnome-boxes
      dbeaver-bin
      kitty
      authenticator
      megasync
      # minigalaxy
      # obs-studio
      bottles
      # jetbrains.webstorm
      # jetbrains-toolbox
      # proton-pass
      vial
      insomnia
      # vopono
      dconf-editor

      # Messengers
      tdesktop
      slack
      discord
      # zoom-us
      # skypeforlinux
      wire-desktop
      mattermost-desktop

      # Graphics
      krita
      gimp

      # gnome
      gnome-tweaks
      gnomeExtensions.syncthing-indicator
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.smart-auto-move
      gnomeExtensions.background-logo

      inputs.devenv.packages.x86_64-linux.devenv
      # wineWowPackages.stable

      # libs
      libunwind # for steam in bottles
      gmsh # for freecad
      calculix # for freecad
      protontricks
      openfortivpn # vpn for dit
      adw-gtk3 # gtk3 theme
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

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          syncthing-indicator.extensionUuid
          tray-icons-reloaded.extensionUuid
          smart-auto-move.extensionUuid
          background-logo.extensionUuid
          # pop-shell.extensionUuid
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
      };
    };
  };

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
      profiles = let
        addons = inputs.firefox-addons.packages."x86_64-linux";
        default-extensions = with addons; [
          sidebery
          tabliss
        ];
        react-extensions = with addons; [
          react-devtools
          reduxdevtools
        ];
        search = {
          force = true;
          default = "ddg";
        };
        settings = {
          "browser.tabs.loadInBackground" = false; # Switch to opened tab
          "browser.ctrlTab.sortByRecentlyUsed" = true; # Ctrl+Tab in recent order
          "browser.startup.page" = 3; # Open previous windows on startup
          "browser.urlbar.showSearchSuggestionsFirst" = false; # Show history first
          "extensions.autoDisableScopes" = 0; # Enable extansions
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable userChrome.css
          "services.sync.engine.tabs" = false;
          "services.sync.engine.prefs" = false;
          "services.sync.engine.addons" = false;
          "devtools.cache.disabled" = true;
        };
        userChrome = ''
          #main-window #TabsToolbar {
          ··transition: visibility 0s 0s;
          }
          #main-window #TabsToolbar .toolbar-items {
          ··overflow: hidden;
          ··transition: height 0.3s 0.3s !important;
          }
          /* Default state: Set initial height to enable animation */
          #main-window #TabsToolbar .toolbar-items { height: 40px !important; }
          /* Hidden state: Hide native tabs strip */
          #main-window[titlepreface*="[Sidebery]"] #TabsToolbar { visibility: collapse; transition: visibility 0s 0.6s !important }
          #main-window[titlepreface*="[Sidebery]"] #TabsToolbar .toolbar-items { height: 0 !important; }
          /* Hidden state: Fix z-index of active pinned tabs */
          #main-window[titlepreface*="[Sidebery]"] #tabbrowser-tabs { z-index: 0 !important; }
        '';
      in {
        personal = {
          inherit settings search userChrome;
          id = 0;
          isDefault = true;
          extensions.packages = (with addons; [ adnauseam proton-pass ]) ++ default-extensions ++ react-extensions;
        };
        kr = {
          inherit settings search userChrome;
          id = 1;
          extensions.packages = default-extensions ++ react-extensions;
        };
      };
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
      profiles.default = {
        enableUpdateCheck = false;
        userSettings = {
          "window.openFoldersInNewWindow" = "on";
          "files.autoSave" = "onWindowChange";
          "workbench.colorTheme" = "Webstorm IntelliJ Darcula Theme";
          "git.autofetch" = true;
          "explorer.confirmDelete" = false;
        };
        extensions = with pkgs.vscode-extensions;
          [
            bbenoist.nix
            # xr0master.webstorm-intellij-darcula-theme
          ];
      };
    };
  };
}
