{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;

  port = types.ints.between 1 65535;

  volumeType = types.submodule {
    options = {
      source = mkOption { type = types.str; };
      target = mkOption { type = types.str; };
      readOnly = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

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
      exposure = mkOption {
        type = types.enum [
          "lan"
          "public"
        ];
        default = "lan";
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
      source = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  serviceType =
    { name, config, ... }:
    {
      options = {
        enable = mkEnableOption "homelab service";

        image = mkOption { type = types.str; };

        containerName = mkOption {
          type = types.str;
          default = name;
        };

        command = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
        };

        entrypoint = mkOption {
          type = types.nullOr (types.listOf types.str);
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
            default = config.expose.mode != "none" && config.expose.protocol == "http";
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
            default = config.expose.mode == "private" || config.expose.mode == "public";
          };
          records = mkOption {
            type = types.attrsOf dnsRecordType;
            default = { };
          };
        };

        container = {
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

    network.name = mkOption {
      type = types.str;
      default = "homelab";
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
      containerName = mkOption {
        type = types.str;
        default = "homelab-caddy";
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
      firewall.allowedTCPPorts = mkOption {
        type = types.listOf port;
        default = [
          80
          443
        ];
      };
      firewall.allowedUDPPorts = mkOption {
        type = types.listOf port;
        default = [ 443 ];
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

    services = mkOption {
      type = types.attrsOf (types.submodule serviceType);
      default = { };
    };

    dns.records = mkOption {
      type = types.attrsOf dnsRecordType;
      default = { };
    };
  };
}
