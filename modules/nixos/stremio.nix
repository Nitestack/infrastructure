# ╭──────────────────────────────────────────────────────────╮
# │ Stremio                                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  environment.systemPackages = [
    # stremio # WARNING: broken; wait until Stremio package with the new `stremio-linux-shell` comes out
  ];
  services.flatpak.packages = [
    {
      appId = "com.stremio.Stremio";
      origin = "flathub-beta";
    }
    "org.freedesktop.Platform.ffmpeg-full//24.08"
  ];
}
