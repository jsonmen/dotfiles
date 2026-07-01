{ pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
      theme = "";
    };

    plugins = [ ];

    initContent = lib.mkAfter ''
      eval "$(direnv hook zsh)"
    '';
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;

      format = "$nix_shell$directory$git_branch$git_status\n$character";
      right_format = "$cmd_duration";

      # --- LEFT SIDE CONFIGURATION ---

      nix_shell = {
        symbol = " ";
        format = "[ $symbol]($style)";
        style = "fg:#89b4fa";
        impure_msg = "";
        pure_msg = "";
        heuristic = false;
        disabled = false;
      };

      directory = {
        # Using a folder icon and cyan path text over a dark blue background (#005f87)
        format = "[  $path ]($style)";
        style = "fg:#b4befe bold";
        truncation_length = 99;
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 0;
      };

      git_branch = {
        symbol = "󰘬 ";
        format = "[ $symbol$branch ]($style)";
        style = "fg:#a6e3a1 bold";
      };

      git_status = {
        # Keeps status indicators inside the green git block
        format = "([$all_status$ahead_behind]($style))";
        style = "fg:#fab387 bold";
      };

      character = {
        success_symbol = "[❯](bold fg:#a6e3a1)";
        error_symbol = "[❯](bold fg:#f38ba8)";
      };

      # --- RIGHT SIDE CONFIGURATION ---

      cmd_duration = {
        min_time = 500;
        format = "[ $duration  ]($style)";
        style = "fg:#f9e2af bold";
      };
    };
  };

}
