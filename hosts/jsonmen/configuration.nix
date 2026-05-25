{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
  ];

  # =========================================================================
  # === 1. SYSTEM, BOOT, & LOCALIZATION ====================================
  # =========================================================================

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ 
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "jsonmen";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # =========================================================================
  # === 2. HARDWARE, DRIVERS, & AUDIO ======================================
  # =========================================================================

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true; 
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

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

  fileSystems."/hdd" = {
    device = "/dev/disk/by-uuid/f240e0a0-a55e-4bd2-b6fc-2b154f66a3c4";
    fsType = "ext4";
    options = [ "defaults" "nofail" ]; 
  };

  # =========================================================================
  # === 3. DESKTOP & DISPLAY ENVIRONMENT ===================================
  # =========================================================================

  programs.hyprland.enable = true;
  
  # --- Light Weight Display Manager ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common = {
      default = [ "gtk" "hyprland" ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    
    # Nvidia specific optimization hooks
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # Custom User Env variables
    DEFAULT_HEADPHONES_ADDRESS = "88:92:CC:86:A8:04";
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

  # =========================================================================
  # === 4. USER ENVIRONMENT & NIX-LD =======================================
  # =========================================================================

  programs.zsh.enable = true;

  users.users.jsonmen = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jsonmen = import ./home.nix;
  };

  # Native Dynamic Link Interceptor for pre-compiled external binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
      glibc
      linuxPackages.nvidia_x11
      cudaPackages.cuda_nvcc
      cudaPackages.cuda_cudart
      cudaPackages.libcublas
    ];
  };

  # =========================================================================
  # === 5. CORE SYSTEM UTILITIES & UTILS ===================================
  # =========================================================================

  services.gvfs.enable = true; 
  programs.adb.enable = true;  

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jsonmen/dotfiles";
  };

  # Only system-wide requirements and base command line tools remain here
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

    # Dev (remove later)
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
  ]; 

  system.stateVersion = "25.11";
}
