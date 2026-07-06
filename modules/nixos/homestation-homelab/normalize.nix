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
    appName:
    lib.filterAttrs (_: service: service.enable) enabledApps.${appName}.services;

  defaultRouteForApp =
    appName:
    let
      app = enabledApps.${appName};
    in
    lib.optional (app.expose.service != null) {
      match = {
        path = [ ];
        not.path = [ ];
      };
      upstream.service = app.expose.service;
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
    defaultRouteForApp = defaultRouteForApp;
    resolvedRoutesForApp =
      appName:
      let
        app = enabledApps.${appName};
      in
      if app.routes != [ ] then app.routes else defaultRouteForApp appName;
    serviceContainerName = homelabLib.serviceContainerName;
    appProjectName = homelabLib.appProjectName;
  };
}
