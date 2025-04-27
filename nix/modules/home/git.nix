# ╭──────────────────────────────────────────────────────────╮
# │ Git                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ theme, pkgs, ... }:
{
  programs = {
    git.enable = true;
    lazygit = {
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
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
  };
  home = {
    packages = with pkgs; [ delta ];
    shellAliases = {
      lg = "lazygit";
    };
  };
  # handled by chezmoi
  xdg.configFile."git/config".enable = false;
}
