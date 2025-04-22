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
    google-chrome
    signal-desktop-bin
    vesktop
  ];
}
