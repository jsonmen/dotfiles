{ pkgs, ... }:
let
  bt-watcher = pkgs.writeShellScriptBin "bt-watcher" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.systemd}/bin:${pkgs.procps}/bin:$PATH"

    # Ensure any old lock directories are cleared on script initialization
    rm -rf /tmp/waybar_bt_lock

    # Using udevadm monitor as user requires access to the systemd sockets
    stdbuf -oL udevadm monitor --subsystem-match=bluetooth | while read -r line; do
        if mkdir /tmp/waybar_bt_lock 2>/dev/null; then
            (
                sleep 0.8
                pkill -SIGRTMIN+8 waybar
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

  systemd.user.services.bt-watcher = {
    Unit = {
      Description = "Bluetooth Event Watcher for Waybar";
      After = [ "bluetooth.target" ];
      PartOf = [ "bluetooth.target" ];
    };

    Service = {
      ExecStart = "${bt-watcher}/bin/bt-watcher";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "bluetooth.target" ];
    };
  };
}
