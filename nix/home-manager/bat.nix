{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    themes."Catppuccin Mocha" = {
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "d3feec47b16a8e99eabb34cdfbaa115541d374fc";
        sha256 = "1g73x0p8pbzb8d1g1x1fwhwf05sj3nzhbhb65811752p5178fh5k";
      };
      file = "themes/Catppuccin Mocha.tmTheme";
    };
  };
}
