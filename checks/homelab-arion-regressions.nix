{
  inputs,
  pkgs,
  system,
}:
let
  lib = inputs.nixpkgs.lib;

  baseModule = {
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };
    boot.loader.grub.devices = [ "/dev/null" ];
    virtualisation.oci-containers.backend = "docker";
    virtualisation.arion.backend = "docker";
    system.stateVersion = "26.05";
  };

  mkSystem =
    extraModules:
    lib.nixosSystem {
      inherit system;
      modules = [
        inputs.arion.nixosModules.arion
        ../modules/nixos/homestation-homelab
        baseModule
      ]
      ++ extraModules;
    };

  goodConfig = mkSystem [
    {
      homestation.homelab = {
        enable = true;
        apps.demo.services.web = {
          enable = true;
          image = "demo:latest";
          restart = "always";
          labels.foo = "bar";
          volumes = [
            {
              type = "volume";
              name = "demo-data";
              target = "/data";
              external = true;
            }
          ];
        };
      };
    }
  ];

  badConfigEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          apps.demo.services.web = {
            enable = true;
            image = "demo:latest";
            volumes = [
              {
                type = "bind";
                source = "../escape";
                target = "/data";
              }
            ];
          };
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  duplicateProjectNamesEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          lanAddress = "127.0.0.1";
          apps."foo_bar" = {
            expose = {
              mode = "private";
              host = "foo1";
              service = "web";
            };
            services.web = {
              enable = true;
              image = "demo:latest";
              port = 80;
            };
          };
          apps."foo-bar" = {
            expose = {
              mode = "private";
              host = "foo2";
              service = "web";
            };
            services.web = {
              enable = true;
              image = "demo:latest";
              port = 80;
            };
          };
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  duplicateServiceNamesEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          lanAddress = "127.0.0.1";
          apps.demo = {
            expose = {
              mode = "private";
              host = "demo";
              service = "api_v1";
            };
            services."api_v1" = {
              enable = true;
              image = "demo:latest";
              port = 80;
            };
            services."api-v1" = {
              enable = true;
              image = "demo:latest";
              port = 81;
            };
          };
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  caddyTransportConfig = mkSystem [
    {
      homestation.homelab = {
        enable = true;
        domain = "example.test";
        lanAddress = "127.0.0.1";
        cloudflared.wildcardIngress = true;
        apps.demo = {
          expose = {
            mode = "public";
            host = "demo";
            protocol = "https";
          };
          routes = [
            {
              upstream.service = "web";
              proxy.transport.http = {
                tls = true;
                tls_insecure_skip_verify = true;
              };
            }
          ];
          services.web = {
            enable = true;
            image = "demo:latest";
            port = 443;
          };
        };
      };
    }
  ];

  goodProject = goodConfig.config.virtualisation.arion.projects."homelab-demo";
  goodService = goodProject.settings.services.web.service;
  goodVolumes = goodProject.settings."docker-compose".volumes;
  goodNetworkService = goodConfig.config.systemd.services.homelab-network or null;
  caddyVolumes =
    caddyTransportConfig.config.virtualisation.oci-containers.containers."homelab-caddy".volumes;
  caddyfileMount = builtins.head caddyVolumes;
  caddyfilePath = builtins.head (lib.splitString ":" caddyfileMount);
  caddyfileText = builtins.readFile caddyfilePath;
  caddyServiceName =
    caddyTransportConfig.config.virtualisation.oci-containers.containers."homelab-caddy".serviceName;
  caddyUnit = caddyTransportConfig.config.systemd.services.${caddyServiceName};
  arionUnit = caddyTransportConfig.config.systemd.services."arion-homelab-demo";
in
assert goodService.restart == "always";
assert goodService.labels.foo == "bar";
assert goodService.container_name == "demo";
assert goodVolumes."demo-data".external == true;
assert goodNetworkService != null;
assert lib.hasInfix "docker network create homelab-edge" goodNetworkService.script;
assert builtins.elem "homelab-network.service" caddyUnit.requires;
assert builtins.elem "homelab-network.service" arionUnit.requires;
assert !badConfigEval.success;
assert !duplicateProjectNamesEval.success;
assert !duplicateServiceNamesEval.success;
assert lib.hasInfix "tls_insecure_skip_verify\n" caddyfileText;
assert !lib.hasInfix "tls true" caddyfileText;
assert !lib.hasInfix "tls_insecure_skip_verify true" caddyfileText;
pkgs.runCommand "homelab-arion-regressions" { } ''
  touch "$out"
''
