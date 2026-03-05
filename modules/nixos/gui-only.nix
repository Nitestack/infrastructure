# ╭──────────────────────────────────────────────────────────╮
# │ GUI Only Configuration                                   │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  ...
}:
{
  # Packages
  environment.systemPackages = with pkgs; [
    # Apps
    anki
    bitwarden-desktop
    feishin
    localsend
    musescore
    obsidian
    protonmail-desktop
    signal-desktop-bin
    spek
    vesktop
  ];
}
