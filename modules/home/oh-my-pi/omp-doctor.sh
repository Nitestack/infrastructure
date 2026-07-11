set -eu

profile_arg="${1:-all}"
case "$profile_arg" in
  private|work|all) ;;
  *)
    echo "usage: omp-doctor [private|work|all]" >&2
    exit 2
    ;;
esac

has_work=0
if [ -n "${OMP_WORK_CONFIG:-}" ]; then
  has_work=1
fi

if [ "$profile_arg" = work ] && [ "$has_work" -eq 0 ]; then
  echo "work profile is not enabled on this host" >&2
  exit 2
fi

failed=0
pending=0

fail() {
  echo "FAIL: $*" >&2
  failed=1
}

pending_step() {
  echo "PENDING: $*"
  pending=1
}

require_link() {
  path="$1"
  if [ ! -L "$path" ] || ! realpath "$path" | grep -q '^/nix/store/'; then
    fail "expected Nix-managed link: $path"
  fi
}

check_selector() {
  json="$1"
  selector="$2"
  provider="${selector%%/*}"
  model="${selector#*/}"
  if ! jq -e --arg provider "$provider" --arg model "$model" '
    .models[]? | select(.provider == $provider and .id == $model)
  ' "$json" >/dev/null; then
    fail "required model unavailable: $selector"
  fi
}

check_profile() {
  profile="$1"
  case "$profile" in
    private)
      overlay="$OMP_PRIVATE_CONFIG"
      selectors='openai-codex/gpt-5.6-luna openai-codex/gpt-5.6-terra openai-codex/gpt-5.6-sol'
      ;;
    work)
      overlay="$OMP_WORK_CONFIG"
      selectors='work-litellm/qwen-3.6-35b-sovereign work-litellm/deepseek-v4-flash-sovereign work-litellm/qwen3-coder-480b work-litellm/claude-sonnet-5 work-litellm/claude-opus-4-8 work-litellm/gemini-2.5-flash work-litellm/gpt-5-mini'
      ;;
  esac

  agent_dir="$HOME/.omp/profiles/$profile/agent"
  echo "Profile: $profile"
  echo "Agent directory: $agent_dir"

  require_link "$agent_dir/models.yml"
  require_link "$agent_dir/AGENTS.md"
  require_link "$agent_dir/RULES.md"

  if realpath "$agent_dir" | grep -q '^/nix/store/'; then
    fail "profile state must be writable outside /nix/store: $agent_dir"
  fi

  if ! "$OMP_BIN" --profile "$profile" config path >/dev/null; then
    fail "cannot resolve profile configuration path for $profile"
    return
  fi

  # OMP v16.4.4 supports --config for launch and models, but not config. The
  # supported models command therefore validates this authoritative overlay.
  if ! "$OMP_BIN" --profile "$profile" models --config "$overlay" --json >/dev/null; then
    fail "invalid OMP settings overlay for $profile"
    return
  fi
  echo "Validated settings overlay: $overlay"

  if [ "$profile" = work ] && [ -z "${LITELLM_API_KEY:-}" ]; then
    fail "LITELLM_API_KEY is not available for work discovery"
    return
  fi

  models_json="$(mktemp)"
  trap 'rm -f "$models_json"' EXIT HUP INT TERM
  provider="${selectors%%/*}"
  if ! "$OMP_BIN" --profile "$profile" models "$provider" --config "$overlay" --json >"$models_json"; then
    if [ "$profile" = private ]; then
      pending_step "private model lookup needs a valid Codex OAuth login; run /login openai-codex"
    else
      fail "LiteLLM model discovery failed"
    fi
    rm -f "$models_json"
    trap - EXIT HUP INT TERM
    return
  fi

  if [ "$profile" = private ]; then
    for selector in $selectors; do
      provider="${selector%%/*}"
      model="${selector#*/}"
      if ! jq -e --arg provider "$provider" --arg model "$model" '
        .models[]? | select(.provider == $provider and .id == $model)
      ' "$models_json" >/dev/null; then
        pending_step "private Codex models are unavailable; run omp-private then /login openai-codex"
        rm -f "$models_json"
        trap - EXIT HUP INT TERM
        return
      fi
    done
  else
    for selector in $selectors; do
      check_selector "$models_json" "$selector"
    done
  fi
  rm -f "$models_json"
  trap - EXIT HUP INT TERM
}

echo "OMP version: $("$OMP_BIN" --version)"
if [ "$("$OMP_BIN" --version)" != "omp/$OMP_VERSION" ]; then
  fail "unexpected OMP version"
fi

if [ "$profile_arg" = all ] || [ "$profile_arg" = private ]; then
  check_profile private
fi
if { [ "$profile_arg" = all ] || [ "$profile_arg" = work ]; } && [ "$has_work" -eq 1 ]; then
  check_profile work
fi

private_dir="$HOME/.omp/profiles/private/agent"
work_dir="$HOME/.omp/profiles/work/agent"
if [ "$private_dir" = "$work_dir" ] || [ "$(realpath -m "$private_dir")" = "$(realpath -m "$work_dir")" ]; then
  fail "private and work state directories are not isolated"
fi

configs="$OMP_PRIVATE_CONFIG $OMP_PRIVATE_MODELS"
if [ "$has_work" -eq 1 ]; then
  configs="$configs $OMP_WORK_CONFIG $OMP_WORK_MODELS"
fi
for config in $configs; do
  if grep -Eq 'Bearer[[:space:]]+[A-Za-z0-9._-]{16,}|apiKey:[[:space:]]*(sk-|sess-|eyJ)' "$config"; then
    fail "possible literal bearer token in declarative config: $config"
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi
if [ "$pending" -ne 0 ]; then
  echo "Doctor completed with pending interactive authentication."
else
  echo "Doctor completed without actionable failures."
fi
