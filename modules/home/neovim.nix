{ pkgs, inputs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    nixpkgs.source = inputs.nixpkgs;

    luaLoader.enable = true;

    extraPackages = with pkgs; [
      ripgrep
      lazygit
      fzf
      fd
      nixfmt
    ];

    # =========================================================================
    # 1. Basic Options & Globals (Merged and Deduplicated)
    # =========================================================================
    globals = {
      mapleader = " ";
      # Disable legacy external runtime execution engines
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
      loaded_python_provider = 0;
    };

    colorschemes.catppuccin.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 4;
      expandtab = true;
      termguicolors = true;
      clipboard = "unnamedplus";
      statusline = "%f %m %= %y %l:%c";
    };

    # =========================================================================
    # 2. Keymaps
    # =========================================================================
    keymaps = [
      {
        mode = "i";
        key = "jj";
        action = "<Esc>";
      }
      {
        mode = "v";
        key = "<";
        action = "<gv";
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
      }
      # --- Delete without changing clipboard ---
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>o";
        action = "\"_d";
        options = {
          desc = "Delete to black hole register (no clipboard)";
          silent = true;
        };
      }

      # --- Paste without changing clipboard ---
      {
        mode = "x";
        key = "<leader>p";
        action = "\"_dP";
        options = {
          desc = "Paste over selection without changing clipboard";
          silent = true;
        };
      }

      # --- Telescope Keymaps ---
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Telescope Find Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Telescope Live Grep (Search Text)";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "Telescope Find Workspace Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>fk";
        action = "<cmd>Telescope keymaps<CR>";
        options.desc = "Telescope Find Active Keymaps";
      }

      # --- Harpoon Management ---
      {
        mode = "n";
        key = "<leader>a";
        action = {
          __raw = "function() require('harpoon'):list():add() end";
        };
        options.desc = "Harpoon: Append file to list";
      }
      {
        mode = "n";
        key = "<leader>h";
        action = {
          __raw = "function() local harpoon = require('harpoon') harpoon.ui:toggle_quick_menu(harpoon:list()) end";
        };
        options.desc = "Harpoon: Toggle quick menu GUI";
      }

      # --- Harpoon Middle-Finger Nav Keys ---
      {
        mode = "n";
        key = "<leader>k";
        action = {
          __raw = "function() require('harpoon'):list():select(1) end";
        };
        options.desc = "Harpoon: Jump to Slot 1";
      }
      {
        mode = "n";
        key = "<leader>i";
        action = {
          __raw = "function() require('harpoon'):list():select(2) end";
        };
        options.desc = "Harpoon: Jump to Slot 2";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = {
          __raw = "function() require('harpoon'):list():select(3) end";
        };
        options.desc = "Harpoon: Jump to Slot 3";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = {
          __raw = "function() require('harpoon'):list():select(4) end";
        };
        options.desc = "Harpoon: Jump to Slot 4";
      }

      # --- Oil File Manager Keymap ---
      {
        mode = "n";
        key = "-";
        action = "<cmd>Oil<CR>";
        options.desc = "Open parent directory in Oil";
      }

      # --- Global LSP Controls ---
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "LSP Hover Documentation";
      }
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        options.desc = "LSP Go to Definition";
      }
      {
        mode = "n";
        key = "gD";
        action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
        options.desc = "LSP Go to Declaration";
      }
      {
        mode = "n";
        key = "gi";
        action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
        options.desc = "LSP Go to Implementation";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        options.desc = "LSP Rename Variable";
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options.desc = "LSP Code Action";
      }
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
        options.desc = "Next Diagnostic Error";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
        options.desc = "Previous Diagnostic Error";
      }
    ];

    autoCmd = [
      {
        event = [ "VimEnter" ];
        pattern = "*";
        command = "highlight Normal guibg=NONE ctermbg=NONE | highlight StatusLine guibg=NONE ctermbg=NONE | highlight StatusLineNC guibg=NONE ctermbg=NONE";
      }
    ];

    # =========================================================================
    # 3. Diagnostic Configuration
    # =========================================================================
    diagnostics = {
      signs = {
        text = {
          "__raw" = ''
            {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.HINT] = "󰠠 ",
              [vim.diagnostic.severity.INFO] = " ",
            }
          '';
        };
      };
    };

    # =========================================================================
    # 4. Plugins
    # =========================================================================
    plugins = {
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "lua"
            "vim"
            "vimdoc"
            "query"
            "python"
            "bash"
            "rust"
            "toml"
            "json"
            "markdown"
          ];
          highlight.enable = true;
          indent.enable = true;
        };
      };

      catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          transparent_background = true;
          term_colors = true;
          integrations = {
            gitsigns = true;
            harpoon = true;
            telescope.enabled = true;
            treesitter = true;
            native_lsp.enabled = true;
          };
        };
      };

      telescope = {
        enable = true;
        fileIgnorePatterns = [
          "^%.git/"
          "^node_modules/"
          "^result/"
          "%.o$"
          "%.pyc$"
          "^target/"
        ];
        vimgrepArguments = [
          "${pkgs.ripgrep}/bin/rg"
          "--color=never"
          "--no-heading"
          "--with-filename"
          "--line-number"
          "--column"
          "--smart-case"
          "--hidden"
        ];
        settings = {
          defaults = {
            mappings = {
              i = {
                "<C-y>" = {
                  __raw = ''
                    function(prompt_bufnr)
                      local action_state = require("telescope.actions.state")
                      local actions = require("telescope.actions")
                      local entry = action_state.get_selected_entry()
                      
                      -- Target correct structural dictionary metadata inside diagnostics arrays
                      if entry then
                        local msg = entry.text or (entry.value and entry.value.message) or entry.display
                        if msg then
                          vim.fn.setreg("+", msg)
                          print("Copied diagnostic: " .. msg)
                        end
                      end
                      actions.close(prompt_bufnr)
                    end
                  '';
                };
              };
              n = {
                "<C-y>" = {
                  __raw = ''
                    function(prompt_bufnr)
                      local action_state = require("telescope.actions.state")
                      local actions = require("telescope.actions")
                      local entry = action_state.get_selected_entry()
                      if entry then
                        local msg = entry.text or (entry.value and entry.value.message) or entry.display
                        if msg then
                          vim.fn.setreg("+", msg)
                          print("Copied diagnostic: " .. msg)
                        end
                      end
                      actions.close(prompt_bufnr)
                    end
                  '';
                };
              };
            };
          };
        };
      };

      gitsigns = {
        enable = true;
        settings = { };
      };
      harpoon = {
        enable = true;
        enableTelescope = false;
      };

      oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          skip_confirm_for_simple_edits = true;
          view_options = {
            show_hidden = true;
          };
        };
      };

      web-devicons.enable = true;

      # =========================================================================
      # Core LSP System Configuration
      # =========================================================================
      lsp = {
        enable = true;
        servers = {
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          clangd = {
            enable = true;
          };
          pyright = {
            enable = true;
            settings = {
              python = {
                # Force Pyright to read the Python binary from your active environment (such as uv's .venv)
                pythonPath = "./.venv/bin/python";
                analysis = {
                  # Directs Pyright to look for third-party packages inside the local virtual environment
                  venvPath = ".";
                  venv = ".venv";
                  autoSearchPaths = true;
                  useLibraryCodeForTypes = true;
                };
              };
            };
          };
          nixd = {
            enable = true;
          };
        };
      };

      # =========================================================================
      # Formatting Engine
      # =========================================================================
      conform-nvim = {
        enable = true;
        settings = {
          notify_on_error = false;
          format_on_save = ''
            function(bufnr)
              return { timeout_ms = 500, lsp_fallback = true }
            end
          '';
          formatters_by_ft = {
            rust = [ "rustfmt" ];
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];
            cuda = [ "clang-format" ];
            python = [ "black" ];
            nix = [ "nixfmt" ];
          };
        };
      };
    };
  };
}
