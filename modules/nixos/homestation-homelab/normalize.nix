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
    if app.expose.targetService != null then
      app.expose.targetService
    else if lib.length svcNames == 1 then
      lib.head svcNames
    else
      null;

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
    serviceContainerName = homelabLib.serviceContainerName;
    appProjectName = homelabLib.appProjectName;
  };
}
