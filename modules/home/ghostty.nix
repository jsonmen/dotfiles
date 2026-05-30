{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    
    # Enable the desktop entry/shortcut wrapper if needed
    enableZshIntegration = true; # Adds shell integration scripts automatically

    # =========================================================================
    # Native Ghostty Parameters (Translated to Nix Syntax)
    # =========================================================================
    settings = {
      theme = "Catppuccin Mocha";
      background-opacity = 0.8;
      background-blur-radius = 70;
      
      # Clean up window decorations for a borderless minimalist layout
      window-decoration = false;
      
      # Match your pure text Neovim layout (ensures Nerd Fonts work out-of-the-box)
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
    };
  };
}
