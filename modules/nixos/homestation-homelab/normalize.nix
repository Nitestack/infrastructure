{
  config,
  lib,
  ...
}:
let
  cfg = config.homestation.homelab;
  homelabLib = import ./lib.nix { inherit cfg lib; };
  enabledApps = lib.filterAttrs (_: app: app.enable) cfg.apps;

  enabledServicesForApp =
    appName: lib.filterAttrs (_: service: service.enable) enabledApps.${appName}.services;

  effectiveExposeService =
    appName:
    let
      app = enabledApps.${appName};
      svcNames = lib.attrNames (enabledServicesForApp appName);
    in
    if app.expose.service != null then
      app.expose.service
    else if lib.length svcNames == 1 then
      lib.head svcNames
    else
      null;

  defaultRouteForApp =
    appName:
    let
      svc = effectiveExposeService appName;
    in
    lib.optional (svc != null) {
      match = {
        path = [ ];
        not.path = [ ];
      };
      upstream.service = svc;
      proxy.headers.request = { };
      proxy.transport.http = { };
      requestBody.maxSize = null;
      encode = [ ];
      extraConfig = "";
    };
in
{
  options.homestation.homelab._internal = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
  };

  config.homestation.homelab._internal = {
    inherit enabledApps enabledServicesForApp;
    effectiveHost = appName: homelabLib.effectiveHost enabledApps.${appName};
    inherit effectiveExposeService;
    defaultRouteForApp = defaultRouteForApp;
    resolvedRoutesForApp =
      appName:
      let
        app = enabledApps.${appName};
      in
      if app.expose.mode == "none" then
        [ ]
      else if app.routes != [ ] then
        app.routes
      else
        defaultRouteForApp appName;
    serviceContainerName = homelabLib.serviceContainerName;
    appProjectName = homelabLib.appProjectName;
  };
}
