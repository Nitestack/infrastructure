# ╭──────────────────────────────────────────────────────────╮
# │ Games                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  # ── Steam ─────────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  environment.systemPackages = with pkgs; [
    heroic
    prismlauncher
    ryubing
  ];

  # Roblox
  services.flatpak.packages = [ "org.vinegarhq.Sober" ];
  services.flatpak.overrides."org.vinegarhq.Sober".Context = {
    filesystems = [
      "xdg-run/app/com.discordapp.Discord:create"
      "xdg-run/discord-ipc-0"
    ];
    devices = [ "input" ];
  };
}
