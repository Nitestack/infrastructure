# ╭──────────────────────────────────────────────────────────╮
# │ Git                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ theme, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Nitestack";
      userEmail = "74626967+Nitestack@users.noreply.github.com";
      aliases = {
        count-lines = "! git log --author=\"$1\" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf \"added lines: %s, removed lines: %s, total lines: %s\\n\", add, subs, loc }' #";
      };
      extraConfig = {
        core.editor = "nvim";
        push.autoSetupRemote = true;
        pull.rebase = true;
        merge.autoStash = true;
        rebase.autoStash = true;
        init.defaultBranch = "main";
        color.ui = true;
      };
      delta.enable = true;
    };
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
  home.shellAliases = {
    lg = "lazygit";
  };
}
