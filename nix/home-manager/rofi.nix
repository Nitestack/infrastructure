# ╭──────────────────────────────────────────────────────────╮
# │ Rofi                                                     │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  config,
  ...
}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    extraConfig = {
      modi = "drun,run,filebrowser";
      show-icons = true;
      display-drun = "";
      display-run = "";
      display-filebrowser = "";
      drun-display-format = "{name}";
    };
    font = "MonaspiceNe Nerd Font Mono 10";
    pass = {
      enable = true;
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        /*
          *
          ***----- Global Properties -----****
        */
        "*" = {
          # Catppuccin
          background = mkLiteral "#1E1D2FFF";
          background-alt = mkLiteral "#282839FF";
          foreground = mkLiteral "#D9E0EEFF";
          selected = mkLiteral "#7AA2F7FF";
          active = mkLiteral "#ABE9B3FF";
          urgent = mkLiteral "#F28FADFF";

          font = "MonaspiceNe Nerd Font Mono 10";

          border-colour = mkLiteral "var(selected)";
          handle-colour = mkLiteral "var(selected)";
          background-colour = mkLiteral "var(background)";
          foreground-colour = mkLiteral "var(foreground)";
          alternate-background = mkLiteral "var(background-alt)";
          normal-background = mkLiteral "var(background)";
          normal-foreground = mkLiteral "var(foreground)";
          urgent-background = mkLiteral "var(urgent)";
          urgent-foreground = mkLiteral "var(background)";
          active-background = mkLiteral "var(active)";
          active-foreground = mkLiteral "var(background)";
          selected-normal-background = mkLiteral "var(selected)";
          selected-normal-foreground = mkLiteral "var(background)";
          selected-urgent-background = mkLiteral "var(active)";
          selected-urgent-foreground = mkLiteral "var(background)";
          selected-active-background = mkLiteral "var(urgent)";
          selected-active-foreground = mkLiteral "var(background)";
          alternate-normal-background = mkLiteral "var(background)";
          alternate-normal-foreground = mkLiteral "var(foreground)";
          alternate-urgent-background = mkLiteral "var(urgent)";
          alternate-urgent-foreground = mkLiteral "var(background)";
          alternate-active-background = mkLiteral "var(active)";
          alternate-active-foreground = mkLiteral "var(background)";
        };

        /*
          *
          ***----- Main Window -----****
        */
        window = {
          # properties for window widget
          transparency = "real";
          location = mkLiteral "center";
          anchor = mkLiteral "center";
          fullscreen = false;
          width = mkLiteral "600px";
          x-offset = mkLiteral "0px";
          y-offset = mkLiteral "0px";

          # properties for all widgets
          enabled = true;
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-colour";
          cursor = "default";
          # Backgroud Colors
          background-color = mkLiteral "@background-colour";
          # Backgroud Image
          # background-image = mkLiteral "url('/path/to/image.png', none)";
          # Simple Linear Gradient
          # background-image = mkLiteral "linear-gradient(red, orange, pink, purple)";
          # Directional Linear Gradient
          # background-image = mkLiteral "linear-gradient(to bottom, pink, yellow, magenta)";
          # Angle Linear Gradient
          # background-image = mkLiteral "linear-gradient(45, cyan, purple, indigo)";
        };

        /*
          *
          ***----- Main Box -----****
        */
        mainbox = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "30px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px 0px 0px 0px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "transparent";
          children = [
            "inputbar"
            "message"
            "listview"
          ];
        };

        /*
          *
          ***----- Inputbar -----****
        */
        inputbar = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-colour";
          children = [
            "textbox-prompt-colon"
            "entry"
            "mode-switcher"
          ];
        };

        prompt = {
          enabled = mkLiteral "true";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        textbox-prompt-colon = {
          enabled = true;
          padding = mkLiteral "5px 0px";
          expand = false;
          str = "";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        entry = {
          enabled = true;
          padding = mkLiteral "5px 0px";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "text";
          placeholder = "Search...";
          placeholder-color = mkLiteral "inherit";
        };
        num-filtered-rows = {
          enabled = true;
          expand = false;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        textbox-num-sep = {
          enabled = true;
          expand = false;
          str = "/";
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        num-rows = {
          enabled = true;
          expand = false;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };
        case-indicator = {
          enabled = true;
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        /*
          *
          ***----- Listview -----****
        */
        listview = {
          enabled = true;
          columns = mkLiteral "1";
          lines = mkLiteral "8";
          cycle = true;
          dynamic = true;
          scrollbar = true;
          layout = mkLiteral "vertical";
          reverse = false;
          fixed-height = true;
          fixed-columns = true;

          spacing = mkLiteral "5px";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-colour";
          cursor = "default";
        };
        scrollbar = {
          handle-width = mkLiteral "5px ";
          handle-color = mkLiteral "@handle-colour";
          border-radius = mkLiteral "10px";
          background-color = mkLiteral "@alternate-background";
        };

        /*
          *
          ***----- Elements -----****
        */
        element = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "5px 10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-colour";
          cursor = mkLiteral "pointer";
        };
        "element normal.normal" = {
          background-color = mkLiteral "var(normal-background)";
          text-color = mkLiteral "var(normal-foreground)";
        };
        "element normal.urgent" = {
          background-color = mkLiteral "var(urgent-background)";
          text-color = mkLiteral "var(urgent-foreground)";
        };
        "element normal.active" = {
          background-color = mkLiteral "var(active-background)";
          text-color = mkLiteral "var(active-foreground)";
        };
        "element selected.normal" = {
          background-color = mkLiteral "var(selected-normal-background)";
          text-color = mkLiteral "var(selected-normal-foreground)";
        };
        "element selected.urgent" = {
          background-color = mkLiteral "var(selected-urgent-background)";
          text-color = mkLiteral "var(selected-urgent-foreground)";
        };
        "element selected.active" = {
          background-color = mkLiteral "var(selected-active-background)";
          text-color = mkLiteral "var(selected-active-foreground)";
        };
        "element alternate.normal" = {
          background-color = mkLiteral "var(alternate-normal-background)";
          text-color = mkLiteral "var(alternate-normal-foreground)";
        };
        "element alternate.urgent" = {
          background-color = mkLiteral "var(alternate-urgent-background)";
          text-color = mkLiteral "var(alternate-urgent-foreground)";
        };
        "element alternate.active" = {
          background-color = mkLiteral "var(alternate-active-background)";
          text-color = mkLiteral "var(alternate-active-foreground)";
        };
        element-icon = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          size = mkLiteral "24px";
          cursor = mkLiteral "inherit";
        };
        element-text = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          highlight = mkLiteral "inherit";
          cursor = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
        };

        /*
          *
          ***----- Mode Switcher -----****
        */
        mode-switcher = {
          enabled = true;
          spacing = mkLiteral "10px";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-colour";
        };
        button = {
          padding = mkLiteral "5px 10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "inherit";
          cursor = mkLiteral "pointer";
        };
        "button selected" = {
          background-color = mkLiteral "var(selected-normal-background)";
          text-color = mkLiteral "var(selected-normal-foreground)";
        };

        /*
          *
          ***----- Message -----****
        */
        message = {
          enabled = true;
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "0px 0px 0px 0px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground-colour";
        };
        textbox = {
          padding = mkLiteral "8px 10px";
          border = mkLiteral "0px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "@alternate-background";
          text-color = mkLiteral "@foreground-colour";
          vertical-align = mkLiteral "0.5";
          horizontal-align = mkLiteral "0.0";
          highlight = mkLiteral "none";
          placeholder-color = mkLiteral "@foreground-colour";
          blink = true;
          markup = true;
        };
        error-message = {
          padding = mkLiteral "10px";
          border = mkLiteral "2px solid";
          border-radius = mkLiteral "10px";
          border-color = mkLiteral "@border-colour";
          background-color = mkLiteral "@background-colour";
          text-color = mkLiteral "@foreground-colour";
        };
      };
  };
}
