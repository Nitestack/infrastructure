{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    attrNames
    attrValues
    concatLists
    concatMap
    concatStringsSep
    filter
    foldl'
    mkIf
    unique
    ;

  cfg = config.homestation.homelab;
  homelab-lib = import ./lib.nix { inherit cfg lib; };
  inherit (homelab-lib)
    containerAttrName
    effectiveHost
    enabledApps
    enabledContainersForApp
    ;

  duplicates =
    values:
    let
      counts = foldl' (
        acc: value:
        acc
        // {
          ${value} = (acc.${value} or 0) + 1;
        }
      ) { } values;
    in
    filter (value: counts.${value} > 1) (unique values);

  enabledContainers = concatMap (
    appName:
    map (containerName: {
      inherit appName containerName;
      container = enabledApps.${appName}.containers.${containerName};
    }) (attrNames (enabledContainersForApp appName))
  ) (attrNames enabledApps);

  generatedContainerNames = map (
    item: containerAttrName item.appName item.containerName item.container
  ) enabledContainers;
  duplicateContainerNames = duplicates generatedContainerNames;

  exposedContainers = filter (item: item.container.expose.mode != "none") enabledContainers;

  exposedHosts = map (item: effectiveHost item.container) (
    filter (item: effectiveHost item.container != null) exposedContainers
  );

  duplicateHosts = duplicates exposedHosts;

  normalizeBind =
    bind:
    if
      builtins.elem bind [
        "*"
        "0.0.0.0"
        "::"
      ]
    then
      "*"
    else
      bind;

  listenerEntries = concatLists (
    map (
      item:
      map (
        listener:
        let
          bind = if listener.bind != null then normalizeBind listener.bind else "*";
        in
        {
          inherit bind;
          portProtocol = "${toString listener.hostPort}/${listener.protocol}";
        }
      ) (attrValues item.container.listeners)
    ) enabledContainers
  );

  listenerKeys = map (listener: "${listener.bind}:${listener.portProtocol}") listenerEntries;
  duplicateListeners = duplicates listenerKeys;
  listenerPortProtocols = unique (map (listener: listener.portProtocol) listenerEntries);
  wildcardConflicts = map (portProtocol: "*:${portProtocol}") (
    filter (
      portProtocol:
      let
        matchingListeners = filter (listener: listener.portProtocol == portProtocol) listenerEntries;
      in
      builtins.length matchingListeners > 1
      && builtins.any (listener: listener.bind == "*") matchingListeners
    ) listenerPortProtocols
  );
  listenerConflicts = unique (duplicateListeners ++ wildcardConflicts);

  autoDnsKeys = map (item: effectiveHost item.container) (
    filter (
      item:
      item.container.edge.enable
      && item.container.dns.enable
      && item.container.expose.mode == "private"
      && effectiveHost item.container != null
    ) enabledContainers
  );

  containerDnsRecordKeys = concatLists (
    map (item: attrNames item.container.dns.records) enabledContainers
  );

  conflictingDnsKeys = filter (key: builtins.elem key containerDnsRecordKeys) autoDnsKeys;

  unknownLibraries = unique (
    concatLists (
      map (
        item:
        concatMap (
          volume:
          if volume.library != null && !builtins.hasAttr volume.library cfg.libraries then
            [ volume.library ]
          else
            [ ]
        ) item.container.volumes
      ) enabledContainers
    )
  );

  containerAssertions = concatMap (
    item:
    let
      path = "homestation.homelab.apps.${item.appName}.containers.${item.containerName}";
      container = item.container;
      enabledContainerNames = attrNames (enabledContainersForApp item.appName);
      host = effectiveHost container;
    in
    [
      {
        assertion = container.expose.mode == "none" || host != null;
        message = "${path} is exposed but has no expose.host or derivable expose.subdomain.";
      }
      {
        assertion =
          container.expose.mode != "tunnel"
          || (
            cfg.cloudflared.enable && cfg.cloudflared.tunnelId != null && config.services.cloudflared.enable
          );
        message = "${path} uses expose.mode = \"tunnel\", but homestation.homelab.cloudflared is disabled, tunnelId is null, or services.cloudflared.enable is false.";
      }
      {
        assertion = !container.caddy.enable || container.edge.enable;
        message = "${path} enables Caddy but edge.enable is false.";
      }
      {
        assertion = !container.caddy.enable || host != null;
        message = "${path} enables Caddy but has no expose.host or derivable expose.subdomain.";
      }
      {
        assertion = !container.caddy.enable || container.expose.port != null;
        message = "${path} enables Caddy but has no expose.port.";
      }
      {
        assertion =
          !container.caddy.enable
          || container.expose.protocol != "https"
          || container.caddy.upstream != null
          || container.caddy.reverseProxyExtraConfig != "";
        message = "${path} uses expose.protocol = \"https\" — set caddy.upstream or configure TLS transport via caddy.reverseProxyExtraConfig.";
      }
      {
        assertion = !container.dns.enable || container.expose.mode != "private" || cfg.lanAddress != null;
        message = "${path} generates private DNS but homestation.homelab.lanAddress is null.";
      }
      {
        assertion = builtins.all (
          dependency: builtins.elem dependency enabledContainerNames
        ) container.dependsOn;
        message = "${path} depends on an unknown or disabled container in app ${item.appName}.";
      }
      {
        assertion = builtins.all (
          volume: (volume.source != null) != (volume.library != null)
        ) container.volumes;
        message = "${path} has a volume with both or neither 'source' and 'library' set (exactly one is required).";
      }
      {
        assertion = builtins.all (
          volume:
          volume.source == null || lib.hasPrefix "/" volume.source || !lib.hasPrefix ".." volume.source
        ) container.volumes;
        message = "${path} has a relative volume source that escapes the app data directory (starts with '..').";
      }
    ]
  ) enabledContainers;
in
{
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.oci-containers.backend == "docker";
        message = "homestation.homelab requires virtualisation.oci-containers.backend = \"docker\".";
      }
      {
        assertion = !cfg.caddy.enable || !config.services.caddy.enable;
        message = "homestation.homelab generates its own Caddy OCI container, so native services.caddy.enable must be false.";
      }
      {
        assertion = duplicateHosts == [ ];
        message = "homestation.homelab has duplicate exposed hostnames: ${concatStringsSep ", " duplicateHosts}.";
      }
      {
        assertion = listenerConflicts == [ ];
        message = "homestation.homelab has duplicate host listeners: ${concatStringsSep ", " listenerConflicts}.";
      }
      {
        assertion = duplicateContainerNames == [ ];
        message = "homestation.homelab has duplicate generated container names: ${concatStringsSep ", " duplicateContainerNames}.";
      }
      {
        assertion = cfg.network.prefix != "";
        message = "homestation.homelab.network.prefix must not be empty (would produce Docker network names with a leading dash).";
      }
      {
        assertion = conflictingDnsKeys == [ ];
        message = "homestation.homelab auto-generated DNS keys conflict with container dns.records: ${concatStringsSep ", " conflictingDnsKeys}.";
      }
      {
        assertion = unknownLibraries == [ ];
        message = "homestation.homelab has volumes referencing unknown libraries: ${concatStringsSep ", " unknownLibraries}.";
      }
    ]
    ++ containerAssertions;
  };
}
