{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab;
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
    if app.expose.targetService != null then
      app.expose.targetService
    else if lib.length svcNames == 1 then
      lib.head svcNames
    else
      null;

in
{
  options.homelab._internal = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
  };

  options.homelab.lib = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Homelab helper functions (appUrl, serviceUrl, effectiveHost, ...) for use in service definitions — avoids re-importing lib.nix by hand.";
  };

  config.homelab._internal = {
    inherit enabledApps enabledServicesForApp;
    effectiveHost = appName: homelabLib.effectiveHost enabledApps.${appName};
    inherit effectiveExposeService;
    serviceContainerName = homelabLib.serviceContainerName;
    appProjectName = homelabLib.appProjectName;
  };

  config.homelab.lib = homelabLib;
}
