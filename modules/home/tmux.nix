{ pkgs, ... }:

let
  tms = pkgs.writeShellScriptBin "tms" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.fd}/bin:${pkgs.fzf}/bin:${pkgs.tmux}/bin:$PATH"

    TMP_FILE=$(mktemp /tmp/tmux-sessionizer.XXXXXX)
    trap 'rm -f "$TMP_FILE"' EXIT

    # Intercept arguments: if "." or "nix" is passed, bypass fzf and use ~/dotfiles
    if [ "$1" = "." ] || [ "$1" = "nix" ]; then
        ABS_TARGET_DIR=$(realpath "$HOME/dotfiles")
    else
        # Fallback to fzf interactive selection if no matching arguments
        if [ -n "$TMUX" ]; then
            tmux display-popup -E "fd --type d --min-depth 1 --max-depth 3 --exclude '*build*' . '$HOME' | fzf > '$TMP_FILE'"
        else
            fd --type d --min-depth 1 --max-depth 3 . "$HOME" | fzf > "$TMP_FILE"
        fi

        if [ -s "$TMP_FILE" ]; then
            TARGET_DIR=$(cat "$TMP_FILE")
            ABS_TARGET_DIR=$(realpath "$TARGET_DIR")
        else
            exit 0 # Exit cleanly if no directory was selected via fzf
        fi
    fi

    # Session processing logic (applies to both fzf and argument paths)
    SESSION_NAME=$(basename "$ABS_TARGET_DIR" | tr ' .:' '___')

    # Condition 1: Tmux server is not running
    if ! tmux info &>/dev/null; then
        cd "$ABS_TARGET_DIR" || exit 1
        tmux new-session -s "$SESSION_NAME"

    # Condition 2: Tmux server is running, but target session does not exist
    elif ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -c "$ABS_TARGET_DIR"
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "$SESSION_NAME"
        else
            tmux attach-session -t "$SESSION_NAME"
        fi

    # Condition 3: Tmux server is running and session exists
    else
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "$SESSION_NAME"
        else
            tmux attach-session -t "$SESSION_NAME"
        fi
    fi
  '';

  # New script to safely handle index-based session switching without escaping bugs
  tmux-harpoon = pkgs.writeShellScriptBin "tmux-harpoon" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.tmux}/bin:$PATH"
    TARGET_INDEX="$1"
    
    # Get the session name at the given index line (1-indexed for sed)
    SESSION_NAME=$(tmux list-sessions -F '#S' 2>/dev/null | sed -n "''${TARGET_INDEX}p")
    
    if [ -n "$SESSION_NAME" ]; then
        tmux switch-client -t "$SESSION_NAME"
    fi
  '';
in
{
  home.packages = [ 
    tms 
    tmux-harpoon
  ];

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

      # --- Tmux Sessionizer Trigger ---
      bind-key -n C-f run-shell -b "tms"

      # --- Status Bar ---
      set -g status-left ""
      set -g status-right '#[fg=#{@thm_text}] [#S]'

      # --- Harpoon Switch ---
      # Passes the target line index directly to our robust helper script
      bind-key -n C-k run-shell -b "tmux-harpoon 1"
      bind-key -n C-i run-shell -b "tmux-harpoon 2"
      bind-key -n C-d run-shell -b "tmux-harpoon 3"
      bind-key -n C-e run-shell -b "tmux-harpoon 4"
    '';
  };
}
