{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    
    # Modernized Unified Layout
    settings = {
      font = "Inter 10";
      padding = "15";
      layer = "top";
      anchor = "top-right";
      default-timeout = 5000;

      border-size = 1;

      # Catppuccin Mocha Colors
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      progress-color = "over #313244";
    };

    extraConfig = ''
      [urgency=high]
      border-color=#fab387
      default-timeout=0
    '';
  };
}
