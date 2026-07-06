{
  config,
  ...
}:
let
  cfg = config.homestation.homelab;
in
{
  homestation.homelab.apps.beszel.containers = {
    beszel = {
      enable = true;
      name = "beszel";
      image = "henrygd/beszel:0.18.7@sha256:a849ad80814b6a1a3be665304dcace5d4854b3bed7bde4dd1227e8ce1b82d477";

      expose = {
        mode = "public";
        host = "status";
        port = 8090;
      };

      environment = {
        APP_URL = "https://status.${cfg.domain}";
      };

      environmentFiles = [ config.sops.secrets."beszel/env".path ];

      volumes = [
        {
          source = "data";
          target = "/beszel_data";
        }
        {
          source = "socket";
          target = "/beszel_socket";
        }
      ];
    };

    agent = {
      enable = true;
      name = "beszel-agent";
      image = "henrygd/beszel-agent:0.18.7-alpine@sha256:c6e925e00784b90eab68e2b813e4c722cf185f378d77e1129a97c064ca5fa7e4";

      environment = {
        LISTEN = "/beszel_socket/beszel.sock";
        HUB_URL = "https://status.${cfg.domain}";
      };

      environmentFiles = [ config.sops.secrets."beszel/env".path ];

      volumes = [
        {
          source = "agent";
          target = "/var/lib/beszel-agent";
        }
        {
          source = "socket";
          target = "/beszel_socket";
        }
        {
          source = "/var/run/docker.sock";
          target = "/var/run/docker.sock";
          readOnly = true;
        }
        {
          source = "/var/run/dbus/system_bus_socket";
          target = "/var/run/dbus/system_bus_socket";
          readOnly = true;
        }
        {
          source = "/.beszel";
          target = "/extra-filesystems/nvme0n1__Data";
          readOnly = true;
        }
        {
          source = "/mnt/backup/.beszel";
          target = "/extra-filesystems/nvme1n1__Backup";
          readOnly = true;
        }
      ];

      extraOptions = [
        "--network=host"
        "--device=/dev/nvme0:/dev/nvme0"
        "--device=/dev/nvme1:/dev/nvme1"
        "--cap-add=SYS_RAWIO"
        "--cap-add=SYS_ADMIN"
      ];
    };
  };
}
