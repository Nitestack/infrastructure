{
  config,
  ...
}:
let
  cfg = config.homelab;
in
{
  homelab.apps.beszel = {
    expose = {
      mode = "public";
      host = "status";
      targetService = "hub";
    };

    services.hub = {
      enable = true;
      image = "henrygd/beszel:0.18.7@sha256:a849ad80814b6a1a3be665304dcace5d4854b3bed7bde4dd1227e8ce1b82d477";
      port = 8090;

      environment = {
        APP_URL = "https://status.${cfg.domain}";
        DISABLE_PASSWORD_AUTH = "true";
      };

      environmentFiles = [ config.sops.templates."beszel-hub.env".path ];

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/beszel_data";
        }
        {
          type = "bind";
          source = "socket";
          target = "/beszel_socket";
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "/beszel"
          "health"
          "--url"
          "http://localhost:8090"
        ];
        interval = "120s";
        startPeriod = "5s";
      };
    };

    services.agent = {
      enable = true;
      image = "henrygd/beszel-agent:0.18.7-alpine@sha256:c6e925e00784b90eab68e2b813e4c722cf185f378d77e1129a97c064ca5fa7e4";

      environment = {
        LISTEN = "/beszel_socket/beszel.sock";
        HUB_URL = "https://status.${cfg.domain}";
        SENSORS = "-acpitz,nvme_sensor_*";
      };

      environmentFiles = [ config.sops.templates."beszel-agent.env".path ];

      volumes = [
        {
          type = "bind";
          source = "agent";
          target = "/var/lib/beszel-agent";
        }
        {
          type = "bind";
          source = "socket";
          target = "/beszel_socket";
        }
        {
          type = "bind";
          source = "/var/run/docker.sock";
          target = "/var/run/docker.sock";
          readOnly = true;
        }
        {
          type = "bind";
          source = "/var/run/dbus/system_bus_socket";
          target = "/var/run/dbus/system_bus_socket";
          readOnly = true;
        }
        {
          # USB-to-NVMe adapter (secondary storage); /mnt/backup must be mounted before the
          # agent container starts. Exposed to beszel for disk usage tracking.
          type = "bind";
          source = "/mnt/backup/.beszel";
          target = "/extra-filesystems/sda__Backup";
          readOnly = true;
        }
      ];

      privileges.networkMode = "host";
      privileges.devices = [
        "/dev/nvme0:/dev/nvme0"
        "/dev/sda:/dev/sda"
      ];
      privileges.capabilities.add = [
        "SYS_RAWIO"
        "SYS_ADMIN"
      ];

      healthcheck = {
        test = [
          "CMD"
          "/agent"
          "health"
        ];
        interval = "120s";
      };
    };
  };
}
