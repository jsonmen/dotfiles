{ pkgs, config, ... }:

let
  cfgRasi = config.lib.formats.rasi;
  literal = cfgRasi.mkLiteral;
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "Inter 12";
    
    theme = {
      # Catppuccin Theme Palette Registration Block
      "*" = {
        rosewater = literal "#f5e0dc";
        flamingo = literal "#f2cdcd";
        pink = literal "#f5c2e7";
        mauve = literal "#cba6f7";
        red = literal "#f38ba8";
        maroon = literal "#eba0ac";
        peach = literal "#fab387";
        yellow = literal "#f9e2af";
        green = literal "#a6e3a1";
        teal = literal "#94e2d5";
        sky = literal "#89dceb";
        sapphire = literal "#74c7ec";
        blue = literal "#89b4fa";
        lavender = literal "#b4befe";
        text = literal "#cdd6f4";
        subtext1 = literal "#bac2de";
        subtext0 = literal "#a6adc8";
        overlay2 = literal "#9399b2";
        overlay1 = literal "#7f849c";
        overlay0 = literal "#6c7086";
        surface2 = literal "#585b70";
        surface1 = literal "#45475a";
        surface0 = literal "#313244";
        base = literal "#1e1e2e";
        mantle = literal "#181825";
        crust = literal "#11111b";

        # Functional Theme Maps
        selected-active-foreground = literal "@background";
        lightfg = literal "@text";
        separatorcolor = literal "@foreground";
        urgent-foreground = literal "@red";
        alternate-urgent-background = literal "@lightbg";
        lightbg = literal "@mantle";
        background-color = literal "transparent";
        border-color = literal "@foreground";
        normal-background = literal "@background";
        selected-urgent-background = literal "@red";
        alternate-active-background = literal "@lightbg";
        spacing = 2;
        alternate-normal-foreground = literal "@foreground";
        urgent-background = literal "@background";
        selected-normal-foreground = literal "@lightbg";
        active-foreground = literal "@blue";
        background = literal "@base";
        selected-active-background = literal "@blue";
        active-background = literal "@background";
        selected-normal-background = literal "@lightfg";
        alternate-normal-background = literal "@lightbg";
        foreground = literal "@text";
        selected-urgent-foreground = literal "@background";
        normal-foreground = literal "@foreground";
        alternate-urgent-foreground = literal "@red";
        alternate-active-foreground = literal "@blue";
      };

      "element" = {
        padding = literal "1px";
        cursor = literal "pointer";
        spacing = literal "5px";
        border = 0;
      };

      "element normal.normal" = {
        background-color = literal "@normal-background";
        text-color = literal "@normal-foreground";
      };

      "element normal.urgent" = {
        background-color = literal "@urgent-background";
        text-color = literal "@urgent-foreground";
      };

      "element normal.active" = {
        background-color = literal "@active-background";
        text-color = literal "@active-foreground";
      };

      "element selected.normal" = {
        background-color = literal "@selected-normal-background";
        text-color = literal "@selected-normal-foreground";
      };

      "element selected.urgent" = {
        background-color = literal "@selected-urgent-background";
        text-color = literal "@selected-urgent-foreground";
      };

      "element selected.active" = {
        background-color = literal "@selected-active-background";
        text-color = literal "@selected-active-foreground";
      };

      "element alternate.normal" = {
        background-color = literal "@alternate-normal-background";
        text-color = literal "@alternate-normal-foreground";
      };

      "element alternate.urgent" = {
        background-color = literal "@alternate-urgent-background";
        text-color = literal "@alternate-urgent-foreground";
      };

      "element alternate.active" = {
        background-color = literal "@alternate-active-background";
        text-color = literal "@alternate-active-foreground";
      };

      "element-text" = {
        background-color = literal "transparent";
        cursor = literal "inherit";
        highlight = literal "inherit";
        text-color = literal "inherit";
      };

      "element-icon" = {
        background-color = literal "transparent";
        size = literal "1.0000em";
        cursor = literal "inherit";
        text-color = literal "inherit";
      };

      "window" = {
        padding = 5;
        background-color = literal "@background";
        border = 1;
      };

      "mainbox" = {
        padding = 0;
        border = 0;
      };

      "message" = {
        padding = literal "1px";
        border-color = literal "@separatorcolor";
        border = literal "2px dash 0px 0px";
      };

      "textbox" = {
        text-color = literal "@foreground";
      };

      "listview" = {
        padding = [ (literal "2px") (literal "0px") (literal "0px") ];
        scrollbar = true;
        border-color = literal "@separatorcolor";
        spacing = literal "2px";
        fixed-height = 0;
        border = literal "2px dash 0px 0px";
      };

      "scrollbar" = {
        width = literal "4px";
        padding = 0;
        handle-width = literal "8px";
        border = 0;
        handle-color = literal "@normal-foreground";
      };

      "sidebar" = {
        border-color = literal "@separatorcolor";
        border = literal "2px dash 0px 0px";
      };

      "button" = {
        cursor = literal "pointer";
        spacing = 0;
        text-color = literal "@normal-foreground";
      };

      "button selected" = {
        background-color = literal "@selected-normal-background";
        text-color = literal "@selected-normal-foreground";
      };

      "num-filtered-rows" = {
        expand = false;
        text-color = literal "Gray";
      };

      "num-rows" = {
        expand = false;
        text-color = literal "Gray";
      };

      "textbox-num-sep" = {
        expand = false;
        str = "/";
        text-color = literal "Gray";
      };

      "inputbar" = {
        padding = literal "1px";
        spacing = literal "0px";
        text-color = literal "@normal-foreground";
        children = map literal [ 
          "prompt" 
          "textbox-prompt-colon" 
          "entry" 
          "num-filtered-rows" 
          "textbox-num-sep" 
          "num-rows" 
          "case-indicator" 
        ];
      };

      "case-indicator" = {
        spacing = 0;
        text-color = literal "@normal-foreground";
      };

      "entry" = {
        text-color = literal "@normal-foreground";
        cursor = literal "text";
        spacing = 0;
        placeholder-color = literal "Gray";
        placeholder = "Type to filter";
      };

      "prompt" = {
        spacing = 0;
        text-color = literal "@normal-foreground";
      };

      "textbox-prompt-colon" = {
        margin = [ (literal "0px") (literal "0.3000em") (literal "0.0000em") (literal "0.0000em") ];
        expand = false;
        str = ":";
        text-color = literal "inherit";
      };
    };
  };
}
