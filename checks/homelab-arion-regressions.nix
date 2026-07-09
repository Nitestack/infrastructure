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
            reverse_proxy 127.0.0.1:1234
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
            reverse_proxy 127.0.0.1:1234
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
  caddyPorts = caddyTransportConfig.config.virtualisation.oci-containers.containers."caddy".ports;
  caddyfileMount = builtins.head caddyVolumes;
  caddyfilePath = builtins.head (lib.splitString ":" caddyfileMount);
  caddyfileText = builtins.readFile caddyfilePath;
  forbiddenMount = builtins.elemAt caddyVolumes 1;
  forbiddenPath = builtins.head (lib.splitString ":" forbiddenMount);
  localWildcardSection = lib.head (lib.splitString "\nhttps://example.test {\n" caddyfileText);
  afterLocalWildcard = lib.last (lib.splitString "\nhttps://foreign.other.test {\n" caddyfileText);
  tunnelWildcardSection = lib.head (
    lib.splitString "\nhttp://example.test:8080 {\n" afterLocalWildcard
  );
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
  firewallTCPPorts = caddyTransportConfig.config.networking.firewall.allowedTCPPorts;
  cloudflareOpenTofuText = builtins.readFile ../opentofu/cloudflare/dns.tf;
  cloudflareOpenTofuReadme = builtins.readFile ../opentofu/cloudflare/README.md;
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
assert lib.hasInfix "https://*.example.test {" caddyfileText;
assert lib.hasInfix "http://*.example.test:8080 {" caddyfileText;
assert lib.hasInfix "@demo host demo.example.test" localWildcardSection;
assert lib.hasInfix "handle @demo {" localWildcardSection;
assert lib.hasInfix "@dns host dns.example.test" localWildcardSection;
assert lib.hasInfix "handle @dns {" localWildcardSection;
assert lib.hasInfix "\nhttps://example.test {\n" caddyfileText;
assert !lib.hasInfix "@demo_apex host" caddyfileText;
assert cloudflaredIngress."*.example.test".service == "http://127.0.0.1:8080";
assert cloudflaredIngress."example.test".service == "http://127.0.0.1:8080";
assert cloudflaredIngress."*.example.test".originRequest.noTLSVerify == null;
assert cloudflaredIngress."*.example.test".originRequest.originServerName == null;
assert builtins.elem "127.0.0.1:8080:8080" caddyPorts;
assert !builtins.elem 8080 firewallTCPPorts;
assert !lib.hasInfix "https://localhost:443" cloudflareOpenTofuText;
assert lib.hasInfix "content = \"\${local.tunnel_id}.cfargotunnel.com\"" cloudflareOpenTofuText;
assert lib.hasInfix "resource \"cloudflare_zone_setting\" \"always_use_https\""
  cloudflareOpenTofuText;
assert lib.hasInfix "setting_id = \"always_use_https\"" cloudflareOpenTofuText;
assert lib.hasInfix "value      = \"on\"" cloudflareOpenTofuText;
assert lib.hasInfix "Cloudflare Tunnel ingress is not managed in OpenTofu."
  cloudflareOpenTofuReadme;
assert lib.hasInfix "modules/nixos/homestation-homelab/cloudflared.nix" cloudflareOpenTofuReadme;
assert lib.hasInfix "http://127.0.0.1:<caddy.tunnelPort>" cloudflareOpenTofuReadme;
assert !lib.hasInfix "Cf-Connecting-Ip" caddyfileText;
assert !lib.hasInfix "@from-tunnel" caddyfileText;
# public wildcard app appears in both listeners
assert lib.hasInfix
  "@demo host demo.example.test\n  handle @demo {\n    handle {\n      reverse_proxy https://demo:443 {\n"
  localWildcardSection;
assert lib.hasInfix
  "@demo host demo.example.test\n  handle @demo {\n    handle {\n      reverse_proxy https://demo:443 {\n"
  tunnelWildcardSection;
# private wildcard app stays local
assert lib.hasInfix
  "@demo-private host private1.example.test\n  handle @demo-private {\n    handle {\n      reverse_proxy demo-private:8080\n    }\n  }"
  localWildcardSection;
# private wildcard app becomes 403 on tunnel listener
assert lib.hasInfix
  "@demo-private host private1.example.test\n  handle @demo-private {\n  handle {\n    error 403\n  }\n  }"
  tunnelWildcardSection;
# local wildcard unknown hosts abort; tunnel wildcard unknown hosts 403
assert lib.hasInfix "handle {\n  abort\n}\n" localWildcardSection;
assert lib.hasInfix "handle {\n  error 403\n}\n" tunnelWildcardSection;
# forbidden-page import and asset passthrough still wired for shared error page
assert lib.length (lib.splitString "import forbidden_403" localWildcardSection) == 2;
assert lib.hasInfix
  "import forbidden_403\nhandle /__403-assets__/* {\n  root * /srv/errors\n  file_server\n}\n  @demo host demo.example.test"
  localWildcardSection;
# extraSiteBlocks still land in local wildcard block
assert lib.hasInfix
  "@dns host dns.example.test\n  handle @dns {\n    reverse_proxy 127.0.0.1:1234\n  }"
  localWildcardSection;
# extraSiteBlocks alone (no declarative private app) still gets the forbidden-page
# import and font passthrough wired into the wildcard block
assert lib.hasInfix "import forbidden_403" extraSiteBlocksOnlyCaddyfileText;
assert lib.hasInfix "handle /__403-assets__/* {\n  root * /srv/errors\n  file_server\n}"
  extraSiteBlocksOnlyCaddyfileText;
# private foreign host stays local but gets dedicated 403-only tunnel block
assert lib.hasInfix
  "https://foreign.other.test {\n  handle {\n    reverse_proxy demo-foreign-private:9090\n  }\n}"
  caddyfileText;
assert lib.hasInfix
  "http://foreign.other.test:8080 {\nimport forbidden_403\nhandle /__403-assets__/* {\n  root * /srv/errors\n  file_server\n}\nhandle {\n  error 403\n}\n\n}"
  caddyfileText;
# public apex app appears in both listeners
assert lib.hasInfix "example.test {\n  handle {\n    reverse_proxy demo-apex:80\n  }\n}"
  caddyfileText;
assert lib.hasInfix "http://example.test:8080 {\n  handle {\n    reverse_proxy demo-apex:80\n  }\n}"
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
