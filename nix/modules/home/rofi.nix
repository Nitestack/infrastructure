# ╭──────────────────────────────────────────────────────────╮
# │ Rofi                                                     │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  config,
  meta,
  theme,
  ...
}:
let
  inherit (meta) font;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    extraConfig = {
      modi = "drun,run,filebrowser";
      show-icons = true;
      display-drun = "Apps";
      display-run = "Run";
      display-filebrowser = "Files";
      display-clipboard = "Clipboard";
      drun-display-format = "{name}\\n[<span weight='light' size='small'><i>({generic})</i></span>]";
    };
    font = "${font.sans.name} 12";
    pass = {
      enable = true;
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        # Global Properties
        "*" =
          let
            inherit (theme.variables)
              windowBgColor
              viewBgColor
              windowFgColor
              accentBgColor
              accentFgColor
              successBgColor
              successFgColor
              errorBgColor
              errorFgColor
              ;
          in
          {
            border-color = mkLiteral accentBgColor;
            handle-color = mkLiteral accentBgColor;
            background-color = mkLiteral windowBgColor;
            foreground-color = mkLiteral windowFgColor;
            alternate-background = mkLiteral viewBgColor;
            normal-background = mkLiteral windowBgColor;
            normal-foreground = mkLiteral windowFgColor;
            urgent-background = mkLiteral errorBgColor;
            urgent-foreground = mkLiteral errorFgColor;
            active-background = mkLiteral successBgColor;
            active-foreground = mkLiteral successFgColor;
            selected-normal-background = mkLiteral accentBgColor;
            selected-normal-foreground = mkLiteral accentFgColor;
            selected-urgent-background = mkLiteral successBgColor;
            selected-urgent-foreground = mkLiteral successFgColor;
            selected-active-background = mkLiteral errorBgColor;
            selected-active-foreground = mkLiteral errorFgColor;
            alternate-normal-background = mkLiteral windowBgColor;
            alternate-normal-foreground = mkLiteral windowFgColor;
            alternate-urgent-background = mkLiteral errorBgColor;
            alternate-urgent-foreground = mkLiteral errorFgColor;
            alternate-active-background = mkLiteral successBgColor;
            alternate-active-foreground = mkLiteral successFgColor;
          };

        # Main Window
        window = {
          # properties for window widget
          transparency = "real";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
          fullscreen = false;
          width = mkLiteral "500px";
          x-offset = mkLiteral "0px";
          y-offset = mkLiteral "0px";

          # properties for all widgets
          enabled = true;
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "2px";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          cursor = "default";
          background-color = mkLiteral "@background-color";
        };

        # Main Box
        mainbox = {
          enabled = true;
          spacing = mkLiteral "15px";
          padding = mkLiteral "30px";
          background-color = mkLiteral "transparent";
          children = [
            "inputbar"
            "mode-switcher"
            "listview"
          ];
        };

        # Inputbar
        inputbar = {
          enabled = true;
          spacing = mkLiteral "15px";
          margin = mkLiteral "0px";
          background-color = mkLiteral "transparent";
          children = [
            "textbox-prompt-colon"
            "entry"
          ];
        };

        textbox-prompt-colon = {
          enabled = true;
          expand = false;
          padding = mkLiteral "12px 16px";
          border = mkLiteral "0px";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "@foreground-color";
          str = "";
          font = "${font.nerd.propoName} 10";
        };

        entry = {
          enabled = true;
          padding = mkLiteral "12px 16px";
          border = mkLiteral "0px";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-color";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "@foreground-color";
          cursor = mkLiteral "text";
          placeholder = "Search...";
          placeholder-color = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        # Listview
        listview = {
          enabled = true;
          columns = 1;
          lines = 5;
          cycle = true;
          dynamic = true;
          scrollbar = false;
          layout = mkLiteral "vertical";
          reverse = false;
          fixed-height = true;
          fixed-columns = true;

          spacing = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          cursor = "default";
        };

        # Elements
        element = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-color";
          cursor = mkLiteral "pointer";
        };
        "element normal.normal" = {
          background-color = mkLiteral "@normal-background";
          text-color = mkLiteral "@normal-foreground";
        };
        "element normal.urgent" = {
          background-color = mkLiteral "@urgent-background";
          text-color = mkLiteral "@urgent-foreground";
        };
        "element normal.active" = {
          background-color = mkLiteral "@active-background";
          text-color = mkLiteral "@active-foreground";
        };
        "element selected.normal" = {
          background-color = mkLiteral "@selected-normal-background";
          text-color = mkLiteral "@selected-normal-foreground";
        };
        "element selected.urgent" = {
          background-color = mkLiteral "@selected-urgent-background";
          text-color = mkLiteral "@selected-urgent-foreground";
        };
        "element selected.active" = {
          background-color = mkLiteral "@selected-active-background";
          text-color = mkLiteral "@selected-active-foreground";
        };
        "element alternate.normal" = {
          background-color = mkLiteral "@alternate-normal-background";
          text-color = mkLiteral "@alternate-normal-foreground";
        };
        "element alternate.urgent" = {
          background-color = mkLiteral "@alternate-urgent-background";
          text-color = mkLiteral "@alternate-urgent-foreground";
        };
        "element alternate.active" = {
          background-color = mkLiteral "@alternate-active-background";
          text-color = mkLiteral "@alternate-active-foreground";
        };
        element-icon = {
          background-color = mkLiteral "transparent";
          size = mkLiteral "48px";
          cursor = mkLiteral "inherit";
        };
        element-text = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        # Mode Switcher
        mode-switcher = {
          enabled = true;
          expand = false;
          spacing = mkLiteral "15px";
          background-color = mkLiteral "transparent";
        };
        button = {
          padding = mkLiteral "10px";
          border-radius = mkLiteral "100%";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "@foreground-color";
          cursor = mkLiteral "pointer";
        };
        "button selected" = {
          background-color = mkLiteral "@selected-normal-background";
          text-color = mkLiteral "@selected-normal-foreground";
        };

        # Message
        error-message = {
          padding = mkLiteral "20px";
          background-color = mkLiteral "@background-color";
          text-color = mkLiteral "@foreground-color";
        };
        textbox = {
          padding = mkLiteral "0px";
          border-radius = mkLiteral "0px";
          text-color = mkLiteral "@foreground-color";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };
      };
  };
}
