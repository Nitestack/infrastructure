# ╭──────────────────────────────────────────────────────────╮
# │ Interactive Only Configuration                           │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    caddy
    python3

    ansible
    ffmpeg
    rclone
  ];
}
