{ config, pkgs, inputs, ... }:

{
  home.username = "jsonmen";
  home.homeDirectory = "/home/jsonmen";
  home.stateVersion = "25.11";

  # --- Import Modules ---
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/home/zsh.nix
    ../../modules/home/tmux.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/waybar.nix
    ../../modules/home/mako.nix
    ../../modules/home/rofi.nix
    ../../modules/home/neovim.nix
  ];

  home.packages = [ ]; 
  programs.home-manager.enable = true;
}
