{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = osConfig.wslstation.aihub;
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "aihub";
      runtimeInputs = with pkgs; [
        coreutils
        gum
        gnugrep
        gnused
      ];
      text = ''
        set -eu

        show_help() {
          gum style --bold --foreground 212 "ai hub"
          printf '\n'
          printf '%s\n' "Launch commands with a selected profile from ai hub."
          printf '\n'
          gum style --bold "Usage"
          printf '%s\n' \
            "  aihub claude [profile] [-- args...]" \
            "  aihub pi [profile] [-- args...]" \
            "  aihub shell [profile] [-- command ...]" \
            "  aihub env [profile] [--format sh|json]" \
            "  aihub help"
          printf '\n'
          gum style --bold "Notes"
          printf '%s\n' \
            "  Omit profile in an interactive terminal to choose one." \
            "  Use aihub env <profile> to print exports for direct shell setup."
        }

                        usage() {
                          show_help >&2
                          exit 2
                        }

                        valid_target() {
                          case "$1" in
                            claude | pi | env | shell | help) return 0 ;;
                            *) return 1 ;;
                          esac
                        }

                        is_profile() {
                          case "$1" in
                        ${lib.concatMapStringsSep "\n" (
                          profile: "    ${profile}) return 0 ;;"
                        ) cfg.profiles}
                            *) return 1 ;;
                          esac
                        }

                        choose_profile() {
                          candidate=""
                          label=""
                          selection=""
                          choices_file=""

                          if [ -n "''${profile:-}" ]; then
                            return 0
                          fi

                          if [ ! -t 0 ] || [ ! -t 1 ]; then
                            echo "aihub: profile required when no interactive terminal is available" >&2
                            exit 1
                          fi

                          choices_file="$(mktemp)"
                          trap 'rm -f "$choices_file"' EXIT

                          for candidate in ${lib.concatStringsSep " " cfg.profiles}; do
                            label_path="/run/secrets/aihub/$candidate-label"
                            if [ -r "$label_path" ]; then
                              label="$(tr -d '\n' < "$label_path")"
                            else
                              label="$candidate"
                            fi

                            if grep -Fqx -- "$label" "$choices_file" 2>/dev/null; then
                              echo "aihub: duplicate profile label '$label'" >&2
                              exit 1
                            fi

                            printf '%s\n' "$label" >> "$choices_file"
                          done

                          status=0
                          selection="$(gum choose --header='Select ai hub profile' < "$choices_file")" || status=$?
                          rm -f "$choices_file"
                          trap - EXIT
                          if [ "$status" -ne 0 ]; then
                            if [ "$status" -eq 1 ] || [ "$status" -eq 130 ]; then
                              echo "aihub: profile selection cancelled" >&2
                              exit 130
                            fi

                            echo "aihub: profile selection failed" >&2
                            exit "$status"
                          fi

                          for candidate in ${lib.concatStringsSep " " cfg.profiles}; do
                            label_path="/run/secrets/aihub/$candidate-label"
                            if [ -r "$label_path" ]; then
                              label="$(tr -d '\n' < "$label_path")"
                            else
                              label="$candidate"
                            fi

                            if [ "$label" = "$selection" ]; then
                              profile="$candidate"
                              break
                            fi
                          done

                          if [ -z "$profile" ]; then
                            echo "aihub: no profile selected" >&2
                            exit 1
                          fi
                        }

                        emit_env() {
                          case "$env_format" in
                            sh)
                              printf 'export AIHUB_PROFILE=%q\n' "$profile"
                              printf 'export AIHUB_API_KEY=%q\n' "$AIHUB_API_KEY"
                              printf 'export AIHUB_BASE_URL=%q\n' "$AIHUB_BASE_URL"
                              printf 'export ANTHROPIC_API_KEY=%q\n' "$AIHUB_API_KEY"
                              printf 'export ANTHROPIC_BASE_URL=%q\n' "$AIHUB_BASE_URL"
                              ;;
                    json)
                      cat <<'__AIHUB_ENV_JSON__'
                {"AIHUB_PROFILE":"$(printf '%s' "$profile" | sed 's/\\/\\\\/g; s/"/\\"/g')","AIHUB_API_KEY":"$(printf '%s' "$AIHUB_API_KEY" | sed 's/\\/\\\\/g; s/"/\\"/g')","AIHUB_BASE_URL":"$(printf '%s' "$AIHUB_BASE_URL" | sed 's/\\/\\\\/g; s/"/\\"/g')","ANTHROPIC_API_KEY":"$(printf '%s' "$AIHUB_API_KEY" | sed 's/\\/\\\\/g; s/"/\\"/g')","ANTHROPIC_BASE_URL":"$(printf '%s' "$AIHUB_BASE_URL" | sed 's/\\/\\\\/g; s/"/\\"/g')"}
        __AIHUB_ENV_JSON__
                      ;;
                            *)
                              echo "aihub: unsupported env format '$env_format'" >&2
                              exit 1
                              ;;
                          esac
                        }

                        if [ "$#" -lt 1 ]; then
                          usage
                        fi

                        target="$1"
                        shift

                        case "$target" in
                          -h | --help)
                            target="help"
                            ;;
                        esac

                        if ! valid_target "$target"; then
                          echo "aihub: unsupported target '$target'" >&2
                          usage
                        fi

                        if [ "$target" = "help" ]; then
                          show_help
                          exit 0
                        fi

                        profile=""
                        env_format="sh"
                        shell_cmd=""

                        while [ "$#" -gt 0 ]; do
                          case "$1" in
                            --)
                              shift
                              break
                              ;;
                            --format)
                              if [ "$target" != "env" ]; then
                                usage
                              fi
                              if [ "$#" -lt 2 ]; then
                                usage
                              fi
                              env_format="$2"
                              shift 2
                              ;;
                            --format=*)
                              if [ "$target" != "env" ]; then
                                usage
                              fi
                              env_format="''${1#--format=}"
                              shift
                              ;;
                            *)
                              if [ -z "$profile" ] && is_profile "$1"; then
                                profile="$1"
                                shift
                                continue
                              fi
                              break
                              ;;
                          esac
                        done

                        if [ "$target" = "env" ] && [ "$#" -gt 0 ]; then
                          usage
                        fi

                        choose_profile

                        if ! is_profile "$profile"; then
                          echo "aihub: unknown profile '$profile'" >&2
                          exit 1
                        fi

                        key_path="/run/secrets/aihub/$profile"
                        base_url_path="/run/secrets/aihub/base-url"

                        if [ ! -r "$key_path" ]; then
                          echo "aihub: missing secret for profile '$profile'" >&2
                          exit 1
                        fi

                        if [ ! -r "$base_url_path" ]; then
                          echo "aihub: missing base URL secret" >&2
                          exit 1
                        fi

                        AIHUB_API_KEY="$(tr -d '\n' < "$key_path")"
                        AIHUB_BASE_URL="$(tr -d '\n' < "$base_url_path")"

                        export AIHUB_PROFILE="$profile"
                        export AIHUB_API_KEY
                        export AIHUB_BASE_URL
                        export ANTHROPIC_API_KEY="$AIHUB_API_KEY"
                        export ANTHROPIC_BASE_URL="$AIHUB_BASE_URL"

                        case "$target" in
                          env)
                            emit_env
                            ;;
                          claude)
                            exec claude "$@"
                            ;;
                          pi)
                            exec pi "$@"
                            ;;
                          shell)
                            if [ "$#" -gt 0 ]; then
                              exec "$@"
                            fi

                            shell_cmd="''${SHELL:-}"
                            if [ -n "''${NU_VERSION:-}" ]; then
                              shell_cmd="$(command -v nu)"
                            elif [ -z "$shell_cmd" ]; then
                              shell_cmd="$(command -v sh)"
                            fi

                            exec "$shell_cmd"
                            ;;
                        esac
      '';
    })
  ];
}
