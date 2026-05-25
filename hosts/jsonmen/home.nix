{ config, pkgs, ... }:

{
  home.username = "jsonmen";
  home.homeDirectory = "/home/jsonmen";
  home.stateVersion = "25.11";

  # --- Import Modules ---
  imports = [
    ../../modules/home/zsh.nix
    ../../modules/home/tmux.nix
  ];

  home.packages = [ ]; 
  programs.home-manager.enable = true;
}
