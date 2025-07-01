# ╭──────────────────────────────────────────────────────────╮
# │ bat                                                      │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Mocha";
    themes."Catppuccin Mocha" = {
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
        sha256 = "1y5sfi7jfr97z1g6vm2mzbsw59j1jizwlmbadvmx842m0i5ak5ll";
      };
      file = "themes/Catppuccin Mocha.tmTheme";
    };
  };
}
