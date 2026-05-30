{ pkgs, ... }:

let
  bt-watcher = pkgs.writeShellScriptBin "bt-watcher" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.systemd}/bin:${pkgs.procps}/bin:$PATH"
    
    # Ensure any old lock directories are cleared on script initialization
    rm -rf /tmp/waybar_bt_lock
    
    stdbuf -oL udevadm monitor --subsystem-match=bluetooth | while read -r line; do
        # mkdir is atomic in POSIX shells, preventing race conditions
        if mkdir /tmp/waybar_bt_lock 2>/dev/null; then
            (
                # Settle window: Wait for the bluetooth stack connection to fully conclude
                sleep 0.8
                
                # Update Waybar layout UI natively
                pkill -SIGRTMIN+8 waybar
                
                # Release the lock for subsequent hardware events
                rm -rf /tmp/waybar_bt_lock
            ) &
        fi
    done
  '';
in
{
  programs.waybar = {
    enable = true;
  };

  home.packages = [
    bt-watcher
  ];

  xdg.configFile."waybar".source = ./config/waybar;

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${bt-watcher}/bin/bt-watcher"
    ];
  };
}
