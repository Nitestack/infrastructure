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

  volumeType = types.submodule (
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

        command = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
        };

        entrypoint = mkOption {
          type = types.nullOr types.str;
          default = null;
        };

        env = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };

        environmentFiles = mkOption {
          type = types.listOf types.path;
          default = [ ];
        };

        volumes = mkOption {
          type = types.listOf volumeType;
          default = [ ];
        };

        networks = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        edge.enable = mkOption {
          type = types.bool;
          default = false;
        };

        expose = {
          mode = mkOption {
            type = types.enum [
              "none"
              "private"
              "public"
              "tunnel"
            ];
            default = "none";
          };
          host = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          subdomain = mkOption {
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
          port = mkOption {
            type = types.nullOr port;
            default = null;
          };
        };

        listeners = mkOption {
          type = types.attrsOf listenerType;
          default = { };
        };

        dependsOn = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        caddy = {
          enable = mkOption {
            type = types.bool;
            default = config.edge.enable && config.expose.mode != "none" && config.expose.protocol == "http";
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
            default = config.edge.enable && config.expose.mode == "private";
          };
          records = mkOption {
            type = types.attrsOf dnsRecordType;
            default = { };
          };
        };

        docker = {
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          autoStart = mkOption {
            type = types.bool;
            default = true;
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
    };

  appType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      containers = mkOption {
        type = types.attrsOf (types.submodule containerType);
        default = { };
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
