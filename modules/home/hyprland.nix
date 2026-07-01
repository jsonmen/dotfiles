{ pkgs, ... }:

{
  # 1. Standard cursor configurations managed natively via Nix
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "catppuccin-mocha-dark-cursors";
    size = 24;
  };

  # 2. Hyprland configuration block
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "hyprlang";

    settings = {
      env = [
        "__GL_VRR_ALLOWED,0"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "NVD_BACKEND,direct"
        "QT_QPA_PLATFORMTHEME,kde"
      ];
    };

    extraConfig = ''
      source = ~/.config/hypr/hyprland.base.conf
    '';
  };

  xdg.configFile."hypr".source = ./config/hypr;
}
