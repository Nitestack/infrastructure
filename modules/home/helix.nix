# ╭──────────────────────────────────────────────────────────╮
# │ Helix                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    package = pkgs.evil-helix;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        trim-trailing-whitespace = true;
        end-of-line-diagnostics = "hint";
        lsp = {
          display-progress-messages = true;
          display-inlay-hints = true;
        };
        cursor-shape.insert = "bar";
        file-picker.hidden = false;
        indent-guides = {
          render = true;
          character = "▏";
        };
        whitespace = {
          render = {
            tab = "all";
            nbsp = "all";
          };
          characters = {
            tab = ">";
            nbsp = "+";
          };
        };
        statusline = {
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "position-percentage"
            "file-encoding"
            "file-type"
            "version-control"
          ];
        };
      };
    };
  };
}
