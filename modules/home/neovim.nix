{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # Let external configurations source your plugins via lazy.nvim
    extraPackages = with pkgs; [
      lua-language-server
      nil # Nix Language Server
      ripgrep
      fd
      gcc
    ];
  };

  # Symlink standard Lua dotfiles straight to ~/.config/nvim
  xdg.configFile."nvim".source = ./config/nvim;
}
