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
        domain = "example.test";
        lanAddress = "127.0.0.1";
        apps.demo.services.web = {
          enable = true;
          image = "demo:latest";
          restart = "always";
          labels.foo = "bar";
          volumes = [
            {
              type = "volume";
              volume = "demo-data";
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
          domain = "example.test";
          lanAddress = "127.0.0.1";
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

  missingDomainEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          lanAddress = "127.0.0.1";
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  missingLanAddressEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          domain = "example.test";
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  globalLoggingOverrideEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          domain = "example.test";
          lanAddress = "127.0.0.1";
          logging.driver = "json-file";
        };
      }
    ]).config.system.build.toplevel.drvPath
  );

  duplicateProjectNamesEval = builtins.tryEval (
    (mkSystem [
      {
        homestation.homelab = {
          enable = true;
          domain = "example.test";
          lanAddress = "127.0.0.1";
          apps."foo_bar" = {
            expose = {
              mode = "private";
              host = "foo1";
              targetService = "web";
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
              targetService = "web";
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
          domain = "example.test";
          lanAddress = "127.0.0.1";
          apps.demo = {
            expose = {
              mode = "private";
              host = "demo";
              targetService = "api_v1";
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
        cloudflared.tunnelId = "test-tunnel";
        caddy.extraHosts = ''
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
            targetService = "web";
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
            targetService = "web";
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
            targetService = "web";
          };
          services.web = {
            enable = true;
            image = "demo:latest";
            port = 9090;
          };
        };
      };
      services.adguardhome.enable = true;
    }
  ];
  goodProject = goodConfig.config.virtualisation.arion.projects.demo;
  goodService = goodProject.settings.services.web.service;
  goodComposeService = goodProject.settings.out.dockerComposeYamlAttrs.services.web;
  goodVolumes = goodProject.settings."docker-compose".volumes;
  goodNetworkService = goodConfig.config.systemd.services.container-edge-network or null;
  caddyVolumes = caddyTransportConfig.config.virtualisation.oci-containers.containers."caddy".volumes;
  caddyPorts = caddyTransportConfig.config.virtualisation.oci-containers.containers."caddy".ports;
  forbiddenMount = builtins.elemAt caddyVolumes 1;
  caddyServiceName =
    caddyTransportConfig.config.virtualisation.oci-containers.containers."caddy".serviceName;
  caddyUnit = caddyTransportConfig.config.systemd.services.${caddyServiceName};
  arionUnit = caddyTransportConfig.config.systemd.services."arion-demo";
  cloudflaredIngress = caddyTransportConfig.config.services.cloudflared.tunnels."test-tunnel".ingress;
  firewallTCPPorts = caddyTransportConfig.config.networking.firewall.allowedTCPPorts;
  adguardRewrites = caddyTransportConfig.config.services.adguardhome.settings.filtering.rewrites;
  removedDnsRecordsOption =
    !(lib.hasAttrByPath [ "homestation" "homelab" "dns" "records" ] caddyTransportConfig.options);
  cloudflareOpenTofuText = builtins.readFile ../opentofu/cloudflare/dns.tf;
  cloudflareOpenTofuReadme = builtins.readFile ../opentofu/cloudflare/README.md;
in
assert goodService.restart == "always";
assert goodService.labels.foo == "bar";
assert goodService.container_name == "demo";
assert goodComposeService.logging.driver == "journald";
assert goodVolumes."demo-data".external == true;
assert goodNetworkService != null;
assert lib.hasInfix "docker network create edge" goodNetworkService.script;
assert builtins.elem "container-edge-network.service" caddyUnit.requires;
assert builtins.elem "container-edge-network.service" arionUnit.requires;
assert !badConfigEval.success;
assert !missingDomainEval.success;
assert !missingLanAddressEval.success;
assert !globalLoggingOverrideEval.success;
assert !duplicateProjectNamesEval.success;
assert !duplicateServiceNamesEval.success;
assert cloudflaredIngress."*.example.test".service == "http://127.0.0.1:8080";
assert cloudflaredIngress."example.test".service == "http://127.0.0.1:8080";
assert cloudflaredIngress."*.example.test".originRequest.noTLSVerify == null;
assert cloudflaredIngress."*.example.test".originRequest.originServerName == null;
assert builtins.elem "127.0.0.1:8080:8080" caddyPorts;
assert !builtins.elem 8080 firewallTCPPorts;
assert
  adguardRewrites == [
    {
      domain = "*.example.test";
      answer = "127.0.0.1";
      enabled = true;
    }
  ];
assert removedDnsRecordsOption;
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
assert lib.hasSuffix ":/srv/errors:ro" forbiddenMount;
pkgs.runCommand "homelab-arion-regressions" { } ''
  touch "$out"
''
