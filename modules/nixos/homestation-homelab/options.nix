{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;

  port = types.ints.between 1 65535;

  libraryType = types.submodule {
    options = {
      path = mkOption { type = types.str; };
      create = mkOption {
        type = types.bool;
        default = false;
      };
      user = mkOption {
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
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      target = mkOption { type = types.str; };
      readOnly = mkOption {
        type = types.bool;
        default = false;
      };
      external = mkOption {
        type = types.bool;
        default = false;
      };
      hostPath = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        type = mkOption {
          type = types.enum [
            "directory"
            "file"
          ];
          default = "directory";
        };
        user = mkOption {
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
  };

  routeType = types.submodule {
    options = {
      match.path = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      match.not.path = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      upstream.service = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      proxy.headers.request = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      proxy.transport.http = mkOption {
        type = types.attrsOf types.bool;
        default = { };
      };
      requestBody.maxSize = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      encode = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };

  serviceType = types.submodule {
    options = {
      enable = mkEnableOption "homelab app service";
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
      volumes = mkOption {
        type = types.listOf volumeType;
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
      runtime = {
        user = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        workingDir = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        init = mkOption {
          type = types.bool;
          default = false;
        };
        tmpfs = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        tty = mkOption {
          type = types.bool;
          default = false;
        };
        stopGracePeriod = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        stopSignal = mkOption {
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
        dns = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        extraHosts = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        sysctls = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };
      };
    };
  };

  legacyVolumeType = types.submodule (
    { config, ... }:
    {
      options = {
        source = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        library = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        target = mkOption { type = types.str; };
        readOnly = mkOption {
          type = types.bool;
          default = false;
        };
        hostPath = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          type = mkOption {
            type = types.enum [
              "directory"
              "file"
            ];
            default = "directory";
          };
          user = mkOption {
            type = types.str;
            default = "root";
          };
          group = mkOption {
            type = types.str;
            default = "root";
          };
          mode = mkOption {
            type = types.str;
            default = if config.hostPath.type == "file" then "0644" else "0755";
          };
        };
      };
    }
  );

  listenerType = types.submodule {
    options = {
      protocol = mkOption {
        type = types.enum [
          "tcp"
          "udp"
        ];
        default = "tcp";
      };
      containerPort = mkOption { type = port; };
      hostPort = mkOption { type = port; };
      bind = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  dnsRecordType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [
          "A"
          "AAAA"
          "CNAME"
        ];
        default = "A";
      };
      value = mkOption { type = types.str; };
      visibility = mkOption {
        type = types.enum [
          "lan"
          "public"
        ];
        default = "lan";
      };
    };
  };

  containerType =
    { config, ... }:
    {
      options = {
        enable = mkEnableOption "homelab app container";

        image = mkOption { type = types.str; };

        cmd = mkOption {
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

        environmentFiles = mkOption {
          type = types.listOf types.path;
          default = [ ];
        };

        volumes = mkOption {
          type = types.listOf legacyVolumeType;
          default = [ ];
        };

        networks = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        edge.enable = mkOption {
          type = types.bool;
          default = config.expose.mode != "none";
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
            description = ''
              Hostname for this service. Special values:
                "@"        → bare domain (apex), e.g. example.com
                "myapp"    → subdomain, e.g. myapp.example.com (when domain is set)
                "a.b.com"  → used as-is (contains a dot)
              null means no host; exposure requires a host to be set.
            '';
          };
          protocol = mkOption {
            type = types.enum [
              "http"
              "https"
            ];
            default = "http";
          };
          port = mkOption {
            type = types.nullOr port;
            default = null;
          };
        };

        listeners = mkOption {
          type = types.listOf listenerType;
          default = [ ];
        };

        dependsOn = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        caddy = {
          enable = mkOption {
            type = types.bool;
            default =
              config.edge.enable
              && config.expose.mode != "none"
              && config.expose.host != null
              && config.expose.port != null;
          };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
          };
          reverseProxyExtraConfig = mkOption {
            type = types.lines;
            default = "";
          };
          upstream = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };

        dns = {
          enable = mkOption {
            type = types.bool;
            default = config.edge.enable && (config.expose.mode == "private" || config.expose.mode == "public");
          };
          records = mkOption {
            type = types.attrsOf dnsRecordType;
            default = { };
          };
        };

        name = mkOption {
          type = types.nullOr types.str;
          default = null;
        };

        autoStart = mkOption {
          type = types.bool;
          default = true;
        };

        restartPolicy = mkOption {
          type = types.enum [
            "no"
            "on-failure"
            "always"
            "unless-stopped"
          ];
          default = "unless-stopped";
        };

        resources = {
          cpu = mkOption {
            type = types.nullOr types.float;
            default = null;
          };
          memory = mkOption {
            type = types.nullOr types.nonEmptyStr;
            default = null;
          };
        };

        labels = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };

        extraOptions = mkOption {
          type = types.listOf types.str;
          default = [ ];
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
        service = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        protocol = mkOption {
          type = types.enum [
            "http"
            "https"
          ];
          default = "http";
        };
      };
      routes = mkOption {
        type = types.listOf routeType;
        default = [ ];
      };
      services = mkOption {
        type = types.attrsOf serviceType;
        default = { };
      };

      # Temporary compatibility for the existing OCI-based callers and modules.
      container = mkOption {
        type = types.nullOr (types.submodule containerType);
        default = null;
        visible = false;
        internal = true;
      };
      containers = mkOption {
        type = types.attrsOf (types.submodule containerType);
        default = { };
        visible = false;
        internal = true;
      };
    };
  };
in
{
  options.homestation.homelab = {
    enable = mkEnableOption "homestation homelab service abstraction";

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    lanAddress = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/homelab";
    };

    network.prefix = mkOption {
      type = types.str;
      default = "homelab";
    };

    edgeNetwork.name = mkOption {
      type = types.str;
      default = "homelab-edge";
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
      wildcardIngress = mkOption {
        type = types.bool;
        default = false;
      };
    };

    caddy = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      enableWithoutServices = mkOption {
        type = types.bool;
        default = false;
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

    dns.records = mkOption {
      type = types.attrsOf dnsRecordType;
      default = { };
    };
  };
}
