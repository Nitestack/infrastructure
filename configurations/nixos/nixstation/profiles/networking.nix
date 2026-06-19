# ╭──────────────────────────────────────────────────────────╮
# │ Networking                                               │
# ╰──────────────────────────────────────────────────────────╯
{
  networking = {
    networkmanager.enable = true;
    hostName = "nixstation";
    firewall = {
      allowedTCPPorts = [
        57621 # Spotify: sync local tracks from fs with mobile devices in the same network
        3000 # web development
      ];
      allowedUDPPorts = [ 5353 ]; # Spotify: enables discovery of Spotify Connect devices
    };
  };
}
