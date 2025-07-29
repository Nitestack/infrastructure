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
    bitwarden-desktop
    musescore
    signal-desktop-bin
    vesktop
  ];
}
