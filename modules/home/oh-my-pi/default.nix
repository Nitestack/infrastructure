# ╭──────────────────────────────────────────────────────────╮
# │ Oh My Pi                                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  flake,
  config,
  osConfig,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  omp = inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.omp;
  privateConfig = ./private.config.yml;
  privateModels = ./private.models.yml;
  workConfig = ./work.config.yml;

  # Only hosts wiring the oh-my-pi-work-* sops templates (currently just
  # wslstation) get the work profile; private-only hosts skip it entirely.
  hasWorkProfile =
    (osConfig.sops.templates or { }) ? "oh-my-pi-work-models-yml"
    && (osConfig.sops.templates or { }) ? "oh-my-pi-work-litellm-base-url";
  workModelsPath = osConfig.sops.templates."oh-my-pi-work-models-yml".path;
  workLitellmBaseUrlPath = osConfig.sops.templates."oh-my-pi-work-litellm-base-url".path;

  private = pkgs.writeShellApplication {
    name = "omp-private";
    text = ''exec ${omp}/bin/omp --profile private --config ${privateConfig} "$@"'';
  };
  work = pkgs.writeShellApplication {
    name = "omp-work";
    text = ''
      if [ -z "''${LITELLM_API_KEY:-}" ]; then
        echo "LITELLM_API_KEY is required for omp-work" >&2
        exit 1
      fi
      exec ${omp}/bin/omp --profile work --config ${workConfig} "$@"
    '';
  };
in
{
  home.file = {
    ".omp/profiles/private/agent/models.yml".source = privateModels;
    ".omp/profiles/private/agent/AGENTS.md".source = ./AGENTS.md;
    ".omp/profiles/private/agent/RULES.md".source = ./RULES.md;
  }
  // lib.optionalAttrs hasWorkProfile {
    ".omp/profiles/work/agent/models.yml".source = config.lib.file.mkOutOfStoreSymlink workModelsPath;
    ".omp/profiles/work/agent/AGENTS.md".source = ./AGENTS.md;
    ".omp/profiles/work/agent/RULES.md".source = ./RULES.md;
  };

  home.packages = [
    (pkgs.writeShellApplication {
      name = "omp";
      text = ''exec ${private}/bin/omp-private "$@"'';
    })
    private
    (pkgs.writeShellApplication {
      name = "omp-doctor";
      runtimeInputs = with pkgs; [
        coreutils
        gnugrep
        jq
      ];
      text = ''
        export OMP_BIN=${omp}/bin/omp
        export OMP_VERSION=${omp.version}
        export OMP_PRIVATE_CONFIG=${privateConfig}
        export OMP_PRIVATE_MODELS=${privateModels}
        ${lib.optionalString hasWorkProfile ''
          export OMP_WORK_CONFIG=${workConfig}
          export OMP_WORK_MODELS=${workModelsPath}
        ''}
        exec ${pkgs.bash}/bin/bash ${./omp-doctor.sh} "$@"
      '';
    })
  ]
  ++ lib.optionals hasWorkProfile [
    work
    (pkgs.writeShellApplication {
      name = "omp-eval";
      runtimeInputs = with pkgs; [
        coreutils
        curl
        jq
      ];
      text = ''
        export OMP_BIN=${omp}/bin/omp
        export OMP_WORK_CONFIG=${workConfig}
        OMP_WORK_LITELLM_BASE_URL="$(cat ${workLitellmBaseUrlPath})"
        export OMP_WORK_LITELLM_BASE_URL
        exec ${pkgs.bash}/bin/bash ${./omp-eval.sh} "$@"
      '';
    })
  ];
}
