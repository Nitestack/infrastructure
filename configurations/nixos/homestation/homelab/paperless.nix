{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab;
  username = config.meta.username;
  inherit (cfg.lib) appUrl;

  # Staged rollout switches; see docs/homestation-paperless.md. Each needs its
  # keys in secrets/hosts/homestation/paperless.yaml before it is flipped.
  # - sso: Pocket ID client (oidc-client-id, oidc-client-secret); also
  #   publishes the app through Cloudflare Tunnel.
  # - mailIntake: Proton Bridge TLS certificate (bridge-certificate).
  # - ssoOnly: hide password login and redirect to Pocket ID. Keep false
  #   while the local account is still needed.
  sso = true;
  ssoOnly = true;
  mailIntake = false;

  userId = toString (
    if config.users.users.${username}.uid != null then config.users.users.${username}.uid else 1000
  );

  # Proton Bridge only listens on host loopback and its TLS certificate is
  # issued for 127.0.0.1. A host socket proxy exposes it on the gateway of a
  # dedicated internal network; a relay in Paperless's network namespace maps
  # that back to 127.0.0.1 so certificate verification still matches.
  bridgeImapPort = 1143;
  mailBridgeName = "br-pmail0";
  mailGateway = "10.233.254.1";
in
{
  homelab.apps.paperless = {
    expose = {
      mode = if sso then "public" else "private";
      host = "docs";
      targetService = "web";
    };

    services.web = {
      enable = true;
      image = "ghcr.io/paperless-ngx/paperless-ngx:3.4.2@sha256:d704e84f88300eb6ab001ab15720a2330ff99169cf9f94d6b8fcc44b63a84c84";
      port = 8000;
      dependsOn = {
        redis.condition = "service_healthy";
        db.condition = "service_healthy";
        gotenberg = { };
        tika = { };
      };

      helpers.timezone = true;

      environment = {
        USERMAP_UID = userId;
        USERMAP_GID = toString config.ids.gids.users;
        PAPERLESS_URL = appUrl cfg.apps.paperless;
        PAPERLESS_TIME_ZONE = config.time.timeZone;
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBHOST = "db";
        PAPERLESS_DBNAME = "paperless";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_REDIS = "redis://redis:6379";
        PAPERLESS_TIKA_ENABLED = "true";
        PAPERLESS_TIKA_ENDPOINT = "http://tika:9998";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://gotenberg:3000";
        PAPERLESS_OCR_LANGUAGE = "deu+eng+vie";
        PAPERLESS_OCR_LANGUAGES = "vie";
        PAPERLESS_SEARCH_LANGUAGE = "de";
        PAPERLESS_AI_ENABLED = "false";
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
        PAPERLESS_EMAIL_USE_TLS = cfg.lib.smtpSecurityMapped {
          starttls = "true";
          forceTls = "false";
          off = "false";
        };
        PAPERLESS_EMAIL_USE_SSL = cfg.lib.smtpSecurityMapped {
          starttls = "false";
          forceTls = "true";
          off = "false";
        };
      }
      // cfg.lib.smtpEnv {
        hostVar = "PAPERLESS_EMAIL_HOST";
        portVar = "PAPERLESS_EMAIL_PORT";
        usernameVar = "PAPERLESS_EMAIL_HOST_USER";
        fromVar = "PAPERLESS_EMAIL_FROM";
      }
      // lib.optionalAttrs sso {
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_DISABLE_REGULAR_LOGIN = lib.boolToString ssoOnly;
        PAPERLESS_REDIRECT_LOGIN_TO_SSO = lib.boolToString ssoOnly;
        PAPERLESS_SOCIAL_AUTO_SIGNUP = "true";
        PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = "true";
        PAPERLESS_ACCOUNT_EMAIL_VERIFICATION = "none";
      }
      // lib.optionalAttrs mailIntake {
        PAPERLESS_EMAIL_CERTIFICATE_LOCATION = "/run/secrets/proton-bridge.crt";
      };

      environmentFiles = [
        config.sops.templates."paperless-web.env".path
      ]
      ++ lib.optional sso config.sops.templates."paperless-oidc.env".path;

      networks = lib.optional mailIntake "paperless-mail";

      volumes = [
        {
          type = "bind";
          source = "data";
          target = "/usr/src/paperless/data";
          owner = username;
          group = "users";
        }
        {
          type = "bind";
          source = "media";
          target = "/usr/src/paperless/media";
          owner = username;
          group = "users";
        }
      ]
      ++ lib.optional mailIntake {
        type = "bind";
        source = config.sops.secrets."paperless/bridge-certificate".path;
        target = "/run/secrets/proton-bridge.crt";
        readOnly = true;
      };
    };

    services.imap-relay = {
      enable = mailIntake;
      image = "docker.io/alpine/socat:1.8.1.3";
      command = [
        "TCP-LISTEN:${toString bridgeImapPort},bind=127.0.0.1,reuseaddr,fork"
        "TCP:${mailGateway}:${toString bridgeImapPort}"
      ];
      dependsOn.web = { };
      runtime.user = "65534:65534";
      privileges.networkMode = "service:web";
      privileges.capabilities.drop = [ "ALL" ];
      extraServiceConfig = {
        read_only = true;
        security_opt = [ "no-new-privileges:true" ];
      };
    };

    services.db = {
      enable = true;
      image = "docker.io/library/postgres:18-alpine";

      environment = {
        POSTGRES_DB = "paperless";
        POSTGRES_USER = "paperless";
      };

      environmentFiles = [ config.sops.templates."paperless-db.env".path ];

      volumes = [
        {
          type = "bind";
          source = "db";
          target = "/var/lib/postgresql";
        }
      ];

      healthcheck = {
        test = [
          "CMD"
          "pg_isready"
          "-U"
          "paperless"
          "-d"
          "paperless"
        ];
        interval = "10s";
        timeout = "5s";
        retries = 10;
        startPeriod = "20s";
      };
    };

    # Task queue only; Paperless re-queues work on restart, so no persistence.
    services.redis = {
      enable = true;
      image = "docker.io/valkey/valkey:9-alpine";
      command = [
        "valkey-server"
        "--save"
        ""
        "--appendonly"
        "no"
      ];

      healthcheck = {
        test = [
          "CMD"
          "valkey-cli"
          "ping"
        ];
        interval = "10s";
        timeout = "3s";
        retries = 10;
      };
    };

    services.gotenberg = {
      enable = true;
      image = "docker.io/gotenberg/gotenberg:8.38";
      command = [
        "gotenberg"
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=^file:///tmp/.*"
      ];
    };

    services.tika = {
      enable = true;
      image = "docker.io/apache/tika:3.3.1.0";
    };
  };

  # Escape hatch: the homelab API only attaches external networks, so the
  # internal, fixed-bridge mail network is declared on the Arion project.
  virtualisation.arion.projects.paperless.settings.networks = lib.mkIf mailIntake {
    paperless-mail = {
      driver = "bridge";
      internal = true;
      driver_opts."com.docker.network.bridge.name" = mailBridgeName;
      ipam.config = [
        {
          subnet = "10.233.254.0/29";
          gateway = mailGateway;
        }
      ];
    };
  };

  networking.firewall.interfaces.${mailBridgeName}.allowedTCPPorts = lib.mkIf mailIntake [
    bridgeImapPort
  ];

  # Host side of the relay: native socket activation forwarding the mail
  # network gateway to Bridge on loopback. FreeBind lets the socket start
  # before Docker creates the bridge interface.
  systemd.sockets.paperless-bridge-proxy = lib.mkIf mailIntake {
    description = "Proton Bridge IMAP proxy for Paperless";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "${mailGateway}:${toString bridgeImapPort}" ];
    socketConfig.FreeBind = true;
  };

  systemd.services.paperless-bridge-proxy = lib.mkIf mailIntake {
    description = "Proton Bridge IMAP proxy for Paperless";
    requires = [ "paperless-bridge-proxy.socket" ];
    after = [ "paperless-bridge-proxy.socket" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString bridgeImapPort}";
      DynamicUser = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
    };
  };
}
