{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;

  port = types.ints.between 1 65535;

  libraryType = types.submodule {
    options.path = mkOption { type = types.str; };
  };

  volumeType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [
          "bind"
          "library"
          "volume"
        ];
        default = "bind";
      };
      source = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      target = mkOption { type = types.str; };
      readOnly = mkOption {
        type = types.bool;
        default = false;
      };
      library = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      volume = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      external = mkOption {
        type = types.bool;
        default = false;
      };
      engineName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Override the engine-level name for a named volume. When null, Docker derives the final name from the project and volume key. Set this only when a container expects an exact pre-known volume name.";
      };
      owner = mkOption {
        type = types.str;
        default = "root";
      };
      group = mkOption {
        type = types.str;
        default = "root";
      };
      mode = mkOption {
        type = types.str;
        default = "0755";
      };
    };
  };

  serviceType = types.submodule {
    options = {
      enable = mkEnableOption "homelab app service";
      containerName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Override the generated container name. When null, the name is derived from the app and service names. Only set this when a container requires a fixed, externally-known name (e.g. Nextcloud AIO).";
      };
      image = mkOption { type = types.str; };
      port = mkOption {
        type = types.nullOr port;
        default = null;
      };
      command = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
      };
      entrypoint = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      environment = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      helpers = {
        userIds = mkOption {
          type = types.bool;
          default = false;
          description = "Inject PUID and PGID derived from the host's primary user defaults.";
        };
        timezone = mkOption {
          type = types.bool;
          default = false;
          description = "Inject TZ from config.time.timeZone.";
        };
      };
      environmentFiles = mkOption {
        type = types.listOf types.path;
        default = [ ];
      };
      volumes = mkOption {
        type = types.listOf volumeType;
        default = [ ];
      };
      ports = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      networks = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      healthcheck = {
        test = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
        };
        interval = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        timeout = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        retries = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        startPeriod = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      dependsOn = mkOption {
        type = types.attrsOf (
          types.submodule {
            options.condition = mkOption {
              type = types.enum [
                "service_started"
                "service_healthy"
                "service_completed_successfully"
              ];
              default = "service_started";
            };
          }
        );
        default = { };
      };
      restart = mkOption {
        type = types.enum [
          "no"
          "on-failure"
          "always"
          "unless-stopped"
        ];
        default = "unless-stopped";
      };
      runtime = {
        user = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      privileges = {
        networkMode = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        privileged = mkOption {
          type = types.bool;
          default = false;
        };
        devices = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        capabilities.add = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        capabilities.drop = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };
      labels = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      extraServiceConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Raw attrs merged last into the Arion service definition. Use as an escape hatch for compose options not covered by the typed API (e.g. security_opt). Values here override typed options.";
      };
    };
  };

  appType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      expose = {
        mode = mkOption {
          type = types.enum [
            "none"
            "private"
            "public"
          ];
          default = "none";
        };
        host = mkOption {
          type = types.nullOr types.nonEmptyStr;
          default = null;
        };
        targetService = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Which service receives incoming traffic for this app. When null and the app has exactly one enabled service, that service is used automatically.";
        };
        protocol = mkOption {
          type = types.enum [
            "http"
            "https"
          ];
          default = "http";
          description = "Protocol Caddy uses when proxying to this service's container. Use \"https\" only when the container itself speaks TLS; \"http\" covers nearly all homelab services.";
        };
        caddyDirectives = mkOption {
          type = types.lines;
          default = "";
          description = "Extra Caddy directives inserted into this app's generated proxy block before reverse_proxy. Use this for small per-app ingress tweaks without replacing the whole generated host handling.";
        };
      };
      services = mkOption {
        type = types.attrsOf serviceType;
        default = { };
      };
    };
  };
in
{
  options.homestation.homelab = {
    enable = mkEnableOption "homestation homelab service abstraction";

    domain = mkOption {
      type = types.str;
      default = "";
      description = "Base domain used to expand short host labels. Must be non-empty when the homelab module is enabled.";
    };

    lanAddress = mkOption {
      type = types.str;
      default = "";
      description = "Host LAN IP used for local DNS and ingress. Must be non-empty when the homelab module is enabled.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/homelab";
    };

    ingressNetwork = mkOption {
      type = types.str;
      default = "edge";
      description = "Name of the shared external Docker network used for ingress traffic between Caddy and exposed app backends.";
    };

    cloudflared = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      tunnelId = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };

    caddy = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      image = mkOption {
        type = types.str;
        default = "caddy:latest";
      };
      ports = mkOption {
        type = types.listOf types.str;
        default = [
          "80:80"
          "443:443"
          "443:443/udp"
        ];
      };
      tunnelPort = mkOption {
        type = types.port;
        default = 8080;
      };
      openFirewall = mkOption {
        type = types.bool;
        default = true;
      };
      environment = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      environmentFiles = mkOption {
        type = types.listOf types.path;
        default = [ ];
      };
      globalConfig = mkOption {
        type = types.lines;
        default = "";
      };
      extraHosts = mkOption {
        type = types.lines;
        default = "";
        description = "Extra hand-written Caddy host handling that should live alongside the generated app hosts.";
      };
      extraVolumes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };

    smtp = {
      host = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "SMTP host shared by homelab apps. Keep passwords in app-specific environmentFiles.";
      };
      port = mkOption {
        type = types.nullOr port;
        default = null;
        description = "SMTP port shared by homelab apps.";
      };
      security = mkOption {
        type = types.enum [
          "starttls"
          "force_tls"
          "off"
        ];
        default = "starttls";
        description = "SMTP transport mode shared by homelab apps.";
      };
      from = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Default sender address for homelab apps that send mail.";
      };
      username = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "SMTP username shared by homelab apps. Keep passwords in app-specific environmentFiles.";
      };
    };

    libraries = mkOption {
      type = types.attrsOf libraryType;
      default = { };
    };

    apps = mkOption {
      type = types.attrsOf appType;
      default = { };
    };

  };
}
