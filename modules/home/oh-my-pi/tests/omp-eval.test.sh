#!/usr/bin/env bash
# Regression tests for omp-eval.sh against fake omp/curl stubs on PATH.
# Run manually: bash modules/home/oh-my-pi/tests/omp-eval.test.sh
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
omp_eval="$script_dir/../omp-eval.sh"

tests_root="$(mktemp -d)"
trap 'rm -rf "$tests_root"' EXIT

fake_bin="$tests_root/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/omp" <<'FAKE_OMP'
#!/bin/sh
case "${FAKE_OMP_MODE:-success}" in
  success)
    case "$*" in
      *MARMOSET*) echo "bravo TOKEN_MARMOSET_7734 line two" ;;
      *"failing test function"*) echo "test_widget_render" ;;
      *"comparison operator"*) echo ">=" ;;
      *"Python function"*) echo "def add(a, b): return a + b" ;;
      *)
        echo "unexpected prompt: $*" >&2
        exit 1
        ;;
    esac
    exit 0
    ;;
  wrong)
    echo "nothing useful here"
    exit 0
    ;;
  crash)
    echo "boom" >&2
    exit 7
    ;;
esac
FAKE_OMP
chmod +x "$fake_bin/omp"

cat >"$fake_bin/curl" <<'FAKE_CURL'
#!/bin/sh
case "${FAKE_CURL_MODE:-empty}" in
  match)
    base="${OMP_EVAL_RUN_ID_BASE:-unknown}"
    printf '[\n'
    first=1
    for task in discovery logreduce review write; do
      if [ "$first" -eq 0 ]; then printf ',\n'; fi
      first=0
      printf '{"request_tags":["omp-eval","run:%s-%s","task:%s"],"prompt_tokens":10,"completion_tokens":5,"spend":0.001}\n' \
        "$base" "$task" "$task"
    done
    printf ']\n'
    ;;
  empty)
    echo '[]'
    ;;
  fail)
    exit 1
    ;;
esac
FAKE_CURL
chmod +x "$fake_bin/curl"

pass=0
fail=0

expect() {
  desc="$1"
  expected="$2"
  actual="$3"
  if [ "$expected" = "$actual" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL: $desc" >&2
    echo "  expected: $expected" >&2
    echo "  actual:   $actual" >&2
  fi
}

# run_case DESC OMP_MODE CURL_MODE WITH_KEY RUN_ID_BASE [ARGS...]
# Sets case_status and case_log (jq array, "[]" if no log file was written).
run_case() {
  omp_mode="$1"
  curl_mode="$2"
  with_key="$3"
  run_id_base="$4"
  shift 4

  case_home="$(mktemp -d)"
  work_config="$case_home/work.config.yml"
  : >"$work_config"

  (
    export HOME="$case_home"
    export PATH="$fake_bin:$PATH"
    export OMP_BIN=omp
    export OMP_WORK_CONFIG="$work_config"
    export OMP_WORK_LITELLM_BASE_URL="http://fake.invalid"
    export FAKE_OMP_MODE="$omp_mode"
    export FAKE_CURL_MODE="$curl_mode"
    if [ "$with_key" = yes ]; then
      export LITELLM_API_KEY="dummy-key"
    else
      unset LITELLM_API_KEY
    fi
    if [ -n "$run_id_base" ]; then
      export OMP_EVAL_RUN_ID_BASE="$run_id_base"
    else
      unset OMP_EVAL_RUN_ID_BASE
    fi
    exec bash "$omp_eval" "$@"
  )
  case_status=$?

  log_file="$case_home/.omp/profiles/work/agent/eval/runs.jsonl"
  if [ -f "$log_file" ]; then
    case_log="$(jq -cs '.' "$log_file")"
  else
    case_log="[]"
  fi
  rm -rf "$case_home"
}

# 1. Missing LITELLM_API_KEY.
run_case success empty no ""
expect "missing key: exit 1" 1 "$case_status"
expect "missing key: no log" "[]" "$case_log"

# 2. Unexpected extra argument.
run_case success empty yes "" "extra-arg"
expect "extra arg: exit 2" 2 "$case_status"
expect "extra arg: no log" "[]" "$case_log"

# 3. Default invocation, successful replies.
run_case success empty yes run3
expect "default success: exit 0" 0 "$case_status"
expect "default success: 3 records" 3 "$(echo "$case_log" | jq 'length')"
expect "default success: tasks" '["discovery","logreduce","review"]' \
  "$(echo "$case_log" | jq -c '[.[].task]')"
expect "default success: all accepted" '["accepted","accepted","accepted"]' \
  "$(echo "$case_log" | jq -c '[.[].verdict]')"

# 4. --include-paid, successful replies.
run_case success empty yes run4 --include-paid
expect "include-paid success: exit 0" 0 "$case_status"
expect "include-paid success: 4 records" 4 "$(echo "$case_log" | jq 'length')"
expect "include-paid success: last model" '"qwen3-coder-480b"' \
  "$(echo "$case_log" | jq -c '.[3].model')"

# 5. Model replies with wrong content.
run_case wrong empty yes run5
expect "wrong reply: exit 1" 1 "$case_status"
expect "wrong reply: all failed" '["failed","failed","failed"]' \
  "$(echo "$case_log" | jq -c '[.[].verdict]')"

# 6. omp binary crashes.
run_case crash empty yes run6
expect "omp crash: exit 1" 1 "$case_status"
expect "omp crash: all failed" '["failed","failed","failed"]' \
  "$(echo "$case_log" | jq -c '[.[].verdict]')"

# 7. Spend log lookup matches: cost/tokens populated.
run_case success match yes run7
expect "cost match: exit 0" 0 "$case_status"
expect "cost match: input_tokens" '[10,10,10]' \
  "$(echo "$case_log" | jq -c '[.[].input_tokens]')"
expect "cost match: output_tokens" '[5,5,5]' \
  "$(echo "$case_log" | jq -c '[.[].output_tokens]')"
expect "cost match: cost" '[0.001,0.001,0.001]' \
  "$(echo "$case_log" | jq -c '[.[].cost]')"

# 8. Spend log lookup fails: cost/tokens stay null, run still succeeds.
run_case success fail yes run8
expect "cost fail: exit 0" 0 "$case_status"
expect "cost fail: input_tokens null" '[null,null,null]' \
  "$(echo "$case_log" | jq -c '[.[].input_tokens]')"
expect "cost fail: cost null" '[null,null,null]' \
  "$(echo "$case_log" | jq -c '[.[].cost]')"

echo
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
