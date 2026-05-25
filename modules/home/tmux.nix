{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    keyMode = "vi";
    shortcut = "a";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_status_style "basic"
          set -g @catppuccin_window_text " #W"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_window_current_number_color "#{@thm_mauve}"
        '';
      }
    ];

    extraConfig = ''
      setw -g pane-base-index 1
      set -g renumber-windows on

      # --- Navigation ---
      bind -n C-h previous-window
      bind -n C-l next-window

      # --- Copy Mode Bindings ---
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # --- Status Bar ---
      set -g status-left ""
      set -g status-right '#[fg=#{@thm_text}] [#S]'
    '';
  };
}
