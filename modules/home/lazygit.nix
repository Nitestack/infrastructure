# ╭──────────────────────────────────────────────────────────╮
# │ Lazygit                                                  │
# ╰──────────────────────────────────────────────────────────╯
{ theme, ... }:
{
  programs.lazygit = {
    enable = true;
    settings =
      let
        inherit (theme.variables)
          accentBgColor
          windowFgColor
          headerbarBorderColor
          warningBgColor
          errorBgColor
          ;
      in
      {
        gui = {
          nerdFontsVersion = "3";
          theme = {
            activeBorderColor = [
              accentBgColor
              "bold"
            ];
            inactiveBorderColor = [ windowFgColor ];
            optionsTextColor = [ accentBgColor ];
            selectedLineBgColor = [ headerbarBorderColor ];
            cherryPickedCommitBgColor = [ headerbarBorderColor ];
            cherryPickedCommitFgColor = [ accentBgColor ];
            unstagedChangesColor = [ errorBgColor ];
            defaultFgColor = [ windowFgColor ];
            searchingActiveBorderColor = [ warningBgColor ];
          };
          authorColors = {
            "*" = windowFgColor;
          };
        };
        os.editPreset = "nvim-remote";
      };
  };
  home.shellAliases.lg = "lazygit";
}
