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

    # Use important system environment variables generated dynamically by Nix
    importantPrefixes = [ "XCURSOR_" "HYPRCURSOR_" "LIBVA_" "GBM_" "NVD_" ];

    settings = {
      # Pass your hardware and runtime environments natively
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GL_VRR_ALLOWED,0"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "NVD_BACKEND,direct"
        "QT_QPA_PLATFORMTHEME,kde"
      ];
    };

    # Append your raw configuration file AND let Nix append the cursor configs dynamically
    extraConfig = ''
      source = ~/.config/hypr/hyprland.base.conf
    '';
  };

  # 3. Target link rename to prevent loop overrides
  # We source it as a base file so extraConfig handles theme overrides safely.
  xdg.configFile."hypr".source = ./config/hypr;
}
