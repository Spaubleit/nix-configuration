{ ... }: {
  boot.loader.systemd-boot.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
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