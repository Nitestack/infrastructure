#!/usr/bin/env bash
# Bounded synthetic evaluator for the work OMP profile. Runs a fixed battery
# of disposable fixtures against the free-model allow-list, plus one paid
# "writer" fixture behind --include-paid. Never accepts free-text prompts.
set -eu

include_paid=false
if [ "${1:-}" = "--include-paid" ]; then
  include_paid=true
  shift
fi

if [ $# -ne 0 ]; then
  echo "usage: omp-eval [--include-paid]" >&2
  exit 2
fi

if [ -z "${LITELLM_API_KEY:-}" ]; then
  echo "LITELLM_API_KEY is required" >&2
  exit 1
fi

state_dir="$HOME/.omp/profiles/work/agent/eval"
mkdir -p "$state_dir"
chmod 700 "$state_dir"
log="$state_dir/runs.jsonl"

work_dir="$(mktemp -d)"
chmod 700 "$work_dir"
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

overall_status=0

# fetch_cost RUN_ID
# Best-effort query of the proxy's own spend log for rows tagged with this
# run. Never fails the caller: any curl/jq problem falls back to nulls, and
# nothing from the response other than token counts and spend is kept.
fetch_cost() {
  local run_id fallback spend_json result
  run_id="$1"
  fallback='{"input_tokens":null,"output_tokens":null,"cost":null}'

  if ! spend_json="$(curl -sS --max-time 10 \
    -H "Authorization: Bearer $LITELLM_API_KEY" \
    "$OMP_WORK_LITELLM_BASE_URL/spend/logs/v2" 2>/dev/null)"; then
    echo "$fallback"
    return
  fi

  if ! result="$(printf '%s' "$spend_json" | jq -c --arg tag "run:$run_id" '
      [ .[]? | select((.request_tags // .metadata.tags // []) | index($tag) != null) ]
      | if length == 0 then
          {input_tokens: null, output_tokens: null, cost: null}
        else
          { input_tokens: (map(.prompt_tokens // 0) | add),
            output_tokens: (map(.completion_tokens // 0) | add),
            cost: (map(.spend // 0) | add) }
        end
    ' 2>/dev/null)" || [ -z "$result" ]; then
    echo "$fallback"
    return
  fi

  echo "$result"
}

# run_task TASK MODEL FIXTURE_NAME FIXTURE_BODY PROMPT NEEDLE
run_task() {
  local task model fixture_name fixture_body prompt needle
  local fixture_dir overlay run_id started_at finished_at
  local reply status verdict validation_result cost_json
  task="$1"
  model="$2"
  fixture_name="$3"
  fixture_body="$4"
  prompt="$5"
  needle="$6"

  fixture_dir="$work_dir/$task"
  mkdir -p "$fixture_dir"
  printf '%s\n' "$fixture_body" >"$fixture_dir/$fixture_name"

  run_id="${OMP_EVAL_RUN_ID_BASE:-$(date -u +%Y%m%dT%H%M%SZ)-$$}-$task"
  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  # Isolated evaluation model config: a brand-new provider key, never the
  # Nix-linked interactive work-litellm provider, carrying a static
  # X-LiteLLM-Tags header baked in by this shell script for this one run.
  # OMP itself only ever sees static YAML; the "dynamic" tag is generated
  # here, not by any OMP feature.
  overlay="$fixture_dir/eval-provider.yml"
  cat >"$overlay" <<EOF
providers:
  work-litellm-eval:
    baseUrl: $OMP_WORK_LITELLM_BASE_URL
    apiKey: LITELLM_API_KEY
    authHeader: true
    api: openai-completions
    discovery:
      type: litellm
    headers:
      X-LiteLLM-Tags: "omp-eval,run:$run_id,task:$task"
EOF
  chmod 600 "$overlay"

  set +e
  reply="$(cd "$fixture_dir" && "$OMP_BIN" --profile work \
    --config "$OMP_WORK_CONFIG" --config "$overlay" \
    --model "work-litellm-eval/$model" -p "$prompt")"
  status=$?
  set -e

  finished_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [ "$status" -eq 0 ] && printf '%s' "$reply" | grep -qF "$needle"; then
    verdict=accepted
    validation_result=passed
  else
    verdict=failed
    validation_result=failed
    overall_status=1
  fi

  cost_json="$(fetch_cost "$run_id")"

  jq -cn \
    --arg run_id "$run_id" \
    --arg profile work \
    --arg model "$model" \
    --arg task "$task" \
    --arg stage synthetic \
    --arg started_at "$started_at" \
    --arg finished_at "$finished_at" \
    --arg validation_result "$validation_result" \
    --arg verdict "$verdict" \
    --argjson cost "$cost_json" \
    '{
      run_id: $run_id,
      profile: $profile,
      model: $model,
      task: $task,
      stage: $stage,
      started_at: $started_at,
      finished_at: $finished_at,
      input_tokens: $cost.input_tokens,
      output_tokens: $cost.output_tokens,
      latency_ms: null,
      cost: $cost.cost,
      validation_result: $validation_result,
      verdict: $verdict
    }' >>"$log"
}

run_task discovery qwen-3.6-35b-sovereign notes.txt \
  "alpha line one
bravo TOKEN_MARMOSET_7734 line two
charlie line three" \
  "Read notes.txt in the current directory and reply with only the one line that contains the word MARMOSET." \
  "MARMOSET"

run_task logreduce deepseek-v4-flash-sovereign test.log \
  "PASS test_alpha
PASS test_bravo
FAIL test_widget_render (AssertionError: expected 3 got 4)
PASS test_charlie" \
  "Read test.log in the current directory and reply with only the name of the failing test function." \
  "test_widget_render"

run_task review gemma-4-26b-sovereign snippet.py \
  "def clamp_index(items, index):
    if index > len(items):
        return items[-1]
    return items[index]" \
  "Read snippet.py in the current directory. It has an off-by-one boundary bug on the if-comparison line. Reply with only the corrected two-character comparison operator." \
  ">="

if [ "$include_paid" = true ]; then
  run_task write qwen3-coder-480b spec.txt \
    "Implement a function named add that takes a and b and returns their sum." \
    "Read spec.txt in the current directory. Reply with only the Python function it describes, no explanation, no markdown fences." \
    "def add("
fi

exit "$overall_status"
