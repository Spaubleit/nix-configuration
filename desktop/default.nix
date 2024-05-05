{ pkgs, ... }: {
    home.packages = [

    ];

    wayland.windowManager.hyprland = {
        enable = true;
        reloadConfig = true;
        systemdIntegration = true;
        recommendedEnvironment = true;

        xwayladn.enable = true;

        settings = {
            "$mod" = "SUPER";
        };
    };
}