{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 1m";
    };
  };
  
  # hosts discovery
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
  
  # keyboard config
  services.xserver.xkb = {
    layout = "us";
    variant = "dvp";
  };

  programs.dconf.profiles = {
    gdm.databases = [{
      settings = {
        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = true;
          remember-numlock-state = true;
        };
      };
    }];
  };
  
  # locale
  time.timeZone = "Europe/Minsk";
  i18n.defaultLocale = "en_US.utf8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.utf8";
    LC_IDENTIFICATION = "en_GB.utf8";
    LC_MEASUREMENT = "en_GB.utf8";
    LC_MONETARY = "en_GB.utf8";
    LC_NAME = "en_GB.utf8";
    LC_NUMERIC = "en_GB.utf8";
    LC_PAPER = "en_GB.utf8";
    LC_TELEPHONE = "en_GB.utf8";
    LC_TIME = "en_GB.utf8";
  };
}