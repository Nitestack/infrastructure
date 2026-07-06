# ╭──────────────────────────────────────────────────────────╮
# │ Tailscale                                                │
# ╰──────────────────────────────────────────────────────────╯
{ config, ... }: {
  services.tailscale = {
    useRoutingFeatures = "server";
    openFirewall = true;
    extraSetFlags = [ "--advertise-routes=192.168.178.0/24" ];
  };
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
