{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrs'
    mkIf
    mkMerge
    nameValuePair
    ;

  cfg = config.homestation.homelab;

  servicesWithGeneratedDns = filterAttrs (
    _: service:
    service.enable
    && service.dns.enable
    && service.expose.host != null
    && (service.expose.mode == "private" || service.expose.mode == "public")
  ) cfg.services;

  generatedRecords = mapAttrs' (
    name: service:
    nameValuePair service.expose.host {
      type = "A";
      value = cfg.lanAddress;
      visibility = if service.expose.mode == "public" then "public" else "lan";
      source = name;
    }
  ) servicesWithGeneratedDns;

  serviceRecords = mapAttrs' (name: service: nameValuePair name service.dns.records) (
    filterAttrs (_: service: service.enable) cfg.services
  );
in
{
  config = mkIf cfg.enable {
    homestation.homelab.dns.records = mkMerge (
      [ generatedRecords ] ++ builtins.attrValues serviceRecords
    );
  };
}
