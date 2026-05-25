{ pkgs, ... }:

{
  # 1. Install Waybar
  programs.waybar = {
    enable = true;
  };

  # 2. Symlink your native JSONC and CSS configurations
  xdg.configFile."waybar".source = ./config/waybar;
}
