{ pkgs, ags, ... }: {

  imports = [ ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./ags;
  };

  home = {

  };
}
