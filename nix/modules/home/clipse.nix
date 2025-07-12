# ╭──────────────────────────────────────────────────────────╮
# │ clipse                                                   │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, theme, ... }:
let
  uwsm-app = "${pkgs.uwsm}/bin/uwsm app --";

  clipse = "${pkgs.clipse}/bin/clipse";
  ghostty = "${pkgs.ghostty}/bin/ghostty";

  class = "com.savedra1.clipse";

  inherit (theme.variables)
    windowFgColor
    headerbarBgColor
    accentColor
    viewFgColor
    accentBgColor
    headerbarFgColor
    successColor
    warningColor
    ;
in
{
  services.clipse = {
    enable = true;
    imageDisplay.type = "kitty";
    theme = {
      useCustomTheme = true;
      TitleFore = windowFgColor;
      TitleBack = headerbarBgColor;
      TitleInfo = accentColor;
      NormalTitle = windowFgColor;
      DimmedTitle = viewFgColor;
      SelectedTitle = accentBgColor;
      NormalDesc = viewFgColor;
      DimmedDesc = headerbarFgColor;
      SelectedDesc = accentBgColor;
      StatusMsg = successColor;
      PinIndicatorColor = warningColor;
      SelectedBorder = accentColor;
      SelectedDescBorder = accentColor;
      FilteredMatch = windowFgColor;
      FilterPrompt = successColor;
      FilterInfo = accentColor;
      FilterText = windowFgColor;
      FilterCursor = warningColor;
      HelpKey = viewFgColor;
      HelpDesc = headerbarFgColor;
      PageActiveDot = accentColor;
      PageInactiveDot = viewFgColor;
      DividerDot = accentColor;
      PreviewedText = windowFgColor;
      PreviewBorder = accentColor;
    };
  };
  wayland.windowManager.hyprland.settings = {
    binddr = [
      "SUPER, V, Toggle Clipboard History, exec, pkill clipse || ${uwsm-app} ${ghostty} --confirm-close-surface=false --class=${class} -e ${clipse}"
    ];
    windowrule = [
      "float, class:^(${class})$"
      "size 622 652, class:^(${class})$"
    ];
  };
}
