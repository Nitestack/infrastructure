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
        cloudflared.tunnelId = "test-tunnel";
        caddy.extraSiteBlocks = ''
          @dns host dns.example.test
          handle @dns {
            handle @from-tunnel {
              error 403
            }
            handle {
              reverse_proxy 127.0.0.1:1234
            }
          }
        '';
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
        apps.demo_apex = {
          expose = {
            mode = "public";
            host = "@";
            service = "web";
          };
          services.web = {
            enable = true;
            image = "demo:latest";
            port = 80;
          };
        };
        apps.demo_private = {
          expose = {
            mode = "private";
            host = "private1";
            service = "web";
          };
          services.web = {
            enable = true;
            image = "demo:latest";
            port = 8080;
          };
        };
        apps.demo_foreign_private = {
          expose = {
            mode = "private";
            host = "foreign.other.test";
            service = "web";
          };
          services.web = {
            enable = true;
            image = "demo:latest";
            port = 9090;
          };
        };
      };
    }
  ];

  # a config with a hand-authored extraSiteBlocks caller but zero declarative
  # private apps: the forbidden-page import/passthrough must still be wired,
  # since extraSiteBlocks content may reference `error 403` on its own
  extraSiteBlocksOnlyConfig = mkSystem [
    {
      homestation.homelab = {
        enable = true;
        domain = "example.test";
        lanAddress = "127.0.0.1";
        caddy.extraSiteBlocks = ''
          @dns host dns.example.test
          handle @dns {
            handle @from-tunnel {
              error 403
            }
            handle {
              reverse_proxy 127.0.0.1:1234
            }
          }
        '';
        apps.demo = {
          expose = {
            mode = "public";
            host = "demo";
          };
          services.web = {
            enable = true;
            image = "demo:latest";
            port = 80;
          };
        };
      };
    }
  ];

  goodProject = goodConfig.config.virtualisation.arion.projects."homelab-demo";
  goodService = goodProject.settings.services.web.service;
  goodVolumes = goodProject.settings."docker-compose".volumes;
  goodNetworkService = goodConfig.config.systemd.services.homelab-network or null;
  caddyVolumes = caddyTransportConfig.config.virtualisation.oci-containers.containers."caddy".volumes;
  caddyfileMount = builtins.head caddyVolumes;
  caddyfilePath = builtins.head (lib.splitString ":" caddyfileMount);
  caddyfileText = builtins.readFile caddyfilePath;
  forbiddenMount = builtins.elemAt caddyVolumes 1;
  forbiddenPath = builtins.head (lib.splitString ":" forbiddenMount);
  wildcardSection = lib.head (lib.splitString "\nexample.test {\n" caddyfileText);
  extraSiteBlocksOnlyCaddyVolumes =
    extraSiteBlocksOnlyConfig.config.virtualisation.oci-containers.containers."caddy".volumes;
  extraSiteBlocksOnlyCaddyfileText = builtins.readFile (
    builtins.head (lib.splitString ":" (builtins.head extraSiteBlocksOnlyCaddyVolumes))
  );
  caddyServiceName =
    caddyTransportConfig.config.virtualisation.oci-containers.containers."caddy".serviceName;
  caddyUnit = caddyTransportConfig.config.systemd.services.${caddyServiceName};
  arionUnit = caddyTransportConfig.config.systemd.services."arion-homelab-demo";
  cloudflaredIngress = caddyTransportConfig.config.services.cloudflared.tunnels."test-tunnel".ingress;
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
assert lib.hasInfix "*.example.test {" caddyfileText;
assert lib.hasInfix "@demo host demo.example.test" wildcardSection;
assert lib.hasInfix "handle @demo {" wildcardSection;
assert lib.hasInfix "@dns host dns.example.test" wildcardSection;
assert lib.hasInfix "handle @dns {" wildcardSection;
assert lib.hasInfix "\nexample.test {\n" caddyfileText;
assert !lib.hasInfix "@demo_apex host" caddyfileText;
assert
  cloudflaredIngress."*.example.test".originRequest.originServerName == "_cloudflared.example.test";
assert
  cloudflaredIngress."example.test".originRequest.originServerName == "_cloudflared.example.test";
# @from-tunnel is defined exactly once in the wildcard block, shared by every private route in it
assert
  lib.length (lib.splitString "@from-tunnel {\n    header Cf-Connecting-Ip *\n  }" wildcardSection)
  == 2;
# a private app in the wildcard block gets wrapped: tunnel-origin requests hit "error 403"
assert lib.hasInfix
  "@demo-private host private1.example.test\n  handle @demo-private {\n  handle @from-tunnel {\n    error 403\n  }\n  handle {\n"
  wildcardSection;
# a public app in the same wildcard block is untouched: no @from-tunnel guard wraps its handle
assert lib.hasInfix "handle @demo {\n    handle {\n" wildcardSection;
assert !lib.hasInfix "handle @demo {\n  handle @from-tunnel" wildcardSection;
# the forbidden-page import and font passthrough are wired once for the wildcard block,
# before the per-app handles, since at least one app in it (demo-private) is private
assert lib.length (lib.splitString "import forbidden_403" wildcardSection) == 2;
assert lib.hasInfix
  "import forbidden_403\nhandle /__403-assets__/* {\n  root * /srv/errors\n  file_server\n}\n  @demo host demo.example.test"
  wildcardSection;
# an extraSiteBlocks caller can reference the shared @from-tunnel matcher directly
# and use `error 403` itself to opt into the same styled error page
assert lib.hasInfix
  "@dns host dns.example.test\n  handle @dns {\n    handle @from-tunnel {\n      error 403\n    }\n    handle {\n"
  wildcardSection;
# extraSiteBlocks alone (no declarative private app) still gets the forbidden-page
# import and font passthrough wired into the wildcard block
assert lib.hasInfix "import forbidden_403" extraSiteBlocksOnlyCaddyfileText;
assert lib.hasInfix "handle /__403-assets__/* {\n  root * /srv/errors\n  file_server\n}"
  extraSiteBlocksOnlyCaddyfileText;
# an app with a foreign/apex host lives in its own top-level block with its own @from-tunnel,
# its own forbidden-page import, and its own font passthrough
assert lib.hasInfix
  "foreign.other.test {\nimport forbidden_403\nhandle /__403-assets__/* {\n  root * /srv/errors\n  file_server\n}\n@from-tunnel {\n  header Cf-Connecting-Ip *\n}\nhandle @from-tunnel {\n  error 403\n}\nhandle {\n"
  caddyfileText;
# a public apex app is untouched: no @from-tunnel guard, forbidden-page import, or font
# passthrough wraps its handle
assert lib.hasInfix "example.test {\n  handle {\n    reverse_proxy demo-apex:80\n  }\n}"
  caddyfileText;
# the shared handle_errors snippet is defined once, before any site block, and preserves
# the 403 status by rewriting to the mounted error page instead of responding directly
assert lib.hasInfix
  "(forbidden_403) {\n  handle_errors 403 {\n    root * /srv/errors\n    rewrite * /403.html\n    file_server\n  }\n}"
  caddyfileText;
# the error-page directory is bind-mounted read-only into the caddy container
assert lib.hasSuffix ":/srv/errors:ro" forbiddenMount;
# the mounted directory actually contains the error page and the self-hosted font,
# at the exact paths the Caddyfile and the page's @font-face reference
assert builtins.pathExists (forbiddenPath + "/403.html");
assert builtins.pathExists (forbiddenPath + "/__403-assets__/inter-var.ttf");
pkgs.runCommand "homelab-arion-regressions" { } ''
  touch "$out"
''
