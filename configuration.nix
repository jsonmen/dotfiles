{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
  ];

  # --- System & Boot ---
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ 
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.configurationLimit = 10;
    };
  };
  systemd.tmpfiles.rules = [
    "L+ /sbin/ldconfig - - - - ${pkgs.writeShellScript "ldconfig-shim" ''
      if [ "$1" = "-p" ]; then
        echo "libcuda.so.1 (libc6,x86-64) => /run/opengl-driver/lib/libcuda.so.1"
        exit 0
      fi
      exec ${pkgs.glibc.bin}/bin/ldconfig "$@"
    ''}"
  ];
  services.gvfs.enable = true;
  programs.adb.enable = true;
  networking.hostName = "jsonmen";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # --- Hardware: Nvidia & Graphics ---
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true; # Open-source kernel module for 20-series+
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # --- Hardware: Bluetooth & Audio ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true;
      ControllerMode = "dual";
      FastConnectable = true;
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Storage ---
  fileSystems."/hdd" = {
    device = "/dev/disk/by-uuid/f240e0a0-a55e-4bd2-b6fc-2b154f66a3c4";
    fsType = "ext4";
    options = [ "defaults" "nofail" ]; 
  };

  # --- Environment Variables ---
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    DEFAULT_HEADPHONES_ADDRESS = "88:92:CC:86:A8:04";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    GDK_DISABLE_WINDOW_HIDE = "1";
  };

  # --- User & Shell ---
  users.users.jsonmen = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
          zlib
          fuse3
          icu
          nss
          openssl
          curl
          expat
          linuxPackages.nvidia_x11
          cudaPackages.cuda_nvcc
          cudaPackages.cuda_cudart
          cudaPackages.libcublas
          glibc
  ];
    # --- Home Manager Configuration ---
  programs.zsh.enable = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.jsonmen = { pkgs, ... }: {
    home.stateVersion = "25.11";
    programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "sudo" ];
          theme = "";
        };
        plugins = [
        {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        ];
        initContent = ''
            eval "$(direnv hook zsh)"
            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
            '';
    };
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
          # --- Your Custom General Settings ---
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

    programs.home-manager.enable = true;
  };

  # --- Desktop Environment & UI ---
  programs.hyprland.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; 
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  fonts = {
    packages = with pkgs; [
      inter
      geist-font
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      serif = [ "Inter" "Noto Serif" "Noto Color Emoji" ];
      sansSerif = [ "Inter" "Noto Sans" "Noto Color Emoji" ];
      monospace = [ "Geist Mono" "JetBrains Mono" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # --- System Tools & Maintenance ---
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos";
  };

  # --- Packages ---
  environment.systemPackages = with pkgs; [
    # System & Terminal
    ghostty
    neovim
    git
    (btop.override { cudaSupport = true; })
    yazi
    zoxide
    fzf
    tmux
    home-manager
    direnv
    nix-direnv   

    # Wayland / Hyprland Rice
    waybar
    mako
    swww
    rofi
    hyprshot
    catppuccin-cursors.mochaDark

    # Apps
    librewolf
    obsidian
    obs-studio
    mpv
    audacity
    pavucontrol   
    kdePackages.kdenlive

    # Development
    python3
    uv
    black
    rustc
    cargo
    rustfmt
    clippy
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
  ];

  system.stateVersion = "25.11";
}
