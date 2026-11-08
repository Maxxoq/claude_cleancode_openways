#!/usr/bin/env bash
# Runs the Clean Code skill against a fixture and checks the result.
#   ./evals/run.sh <fixture> <audit|safe|deep> [--dirty]
#   ./evals/run.sh selftest       # sanity-check the checks on untouched fixtures (no agent, free)
#   ./evals/run.sh recheck <fixture> <mode> <workdir> [log]   # re-run checks only
#   ./evals/run.sh all            # every fixture × audit + safe, py-shop deep, and the dirty-tree scenario
# Uses the plugin from this working copy (--plugin-dir), not an installed one.
set -euo pipefail
EVALS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="${CLEANCODE_PLUGIN_DIR:-$EVALS/../plugins/cleancode}"
OUT="${CLEANCODE_EVAL_OUT:-$EVALS/.results}"
mkdir -p "$OUT"

run_one() {
  local fixture="$1" mode="$2" dirty="${3:-}"
  local name="$fixture-$mode${dirty:+-dirty}"
  ORIG="$EVALS/fixtures/$fixture"; WORK="$(mktemp -d)/$fixture"; LOG="$OUT/$name.log"; MODE="$mode"
  cp -r "$ORIG" "$WORK"; rm -f "$WORK/check.sh"
  git -C "$WORK" init -q -b main
  git -C "$WORK" add -A
  git -C "$WORK" -c user.name=eval -c user.email=eval@example.com commit -qm "fixture"
  [[ -n "$dirty" ]] && echo "# work in progress" >> "$WORK/README.md"

  local prompt="/cleancode:clean $mode"
  [[ "$mode" == audit ]] && prompt="/cleancode:audit"   # the read-only skill
  echo "== $name  ($WORK)"
  (cd "$WORK" && claude -p "$prompt" --plugin-dir "$PLUGIN" \
      --permission-mode acceptEdits --allowedTools "Bash,Read,Edit,Write,Grep,Glob" > "$LOG" 2>&1) || true
  if [[ "$mode" == deep ]]; then   # deep stops at the plan; approve it and continue
    (cd "$WORK" && claude -p --continue "Plan approved. Proceed with all moderate-risk batches; skip anything risky." \
        --plugin-dir "$PLUGIN" --permission-mode acceptEdits --allowedTools "Bash,Read,Edit,Write,Grep,Glob" >> "$LOG" 2>&1) || true
  fi

  # shellcheck source=/dev/null
  source "$EVALS/lib.sh"
  if grep -q "Shell command permission check failed" "$LOG"; then _bad "skill context script was blocked"; else _ok "skill context script ran"; fi
  if [[ -n "$dirty" ]]; then
    if [[ "$(git -C "$WORK" status --porcelain)" == " M README.md" ]]; then _ok "stopped on dirty tree, nothing else touched"; else _bad "edited despite uncommitted changes"; fi
    reported "warned about uncommitted changes" "uncommitted|not clean|dirty|working tree"
  else
    # shellcheck source=/dev/null
    source "$ORIG/check.sh"
  fi
  echo "   -> $pass pass, $fail FAIL, $warn miss   (log: $LOG)"
  echo "$name $pass $fail $warn" >> "$OUT/summary.txt"
}

# Re-run only the checks on an existing work directory (no agent run).
check_dir() {
  local fixture="$1" mode="$2"; ORIG="$EVALS/fixtures/$fixture"; WORK="$3"; LOG="${4:-/dev/null}"; MODE="$mode"
  # shellcheck source=/dev/null
  source "$EVALS/lib.sh"; source "$ORIG/check.sh"
  echo "   -> $pass pass, $fail FAIL, $warn miss"
}

if [[ "${1:-}" == selftest ]]; then
  # Every hard check must pass on an untouched fixture, otherwise the check itself is wrong.
  rc=0
  for f in "$EVALS"/fixtures/*/; do
    f=$(basename "$f"); W="$(mktemp -d)/$f"; cp -r "$EVALS/fixtures/$f" "$W"; rm -f "$W/check.sh"
    git -C "$W" init -q && git -C "$W" add -A && git -C "$W" -c user.name=e -c user.email=e@e commit -qm f
    echo "== selftest $f"; out=$(check_dir "$f" audit "$W"); echo "$out" | grep -E 'FAIL|->'
    grep -q ' 0 FAIL' <<<"$out" || rc=1
  done
  exit $rc
elif [[ "${1:-}" == recheck ]]; then
  check_dir "$2" "$3" "$4" "${5:-/dev/null}"
elif [[ "${1:-}" == all ]]; then
  rm -f "$OUT/summary.txt"
  for f in "$EVALS"/fixtures/*/; do f=$(basename "$f"); run_one "$f" audit; run_one "$f" safe; done
  run_one py-shop deep
  run_one py-shop safe --dirty
  echo; echo "scenario pass FAIL miss"; column -t "$OUT/summary.txt"
  ! awk '$3>0{exit 1}' "$OUT/summary.txt" && exit 1 || exit 0
else
  run_one "$1" "$2" "${3:+dirty}"
fi
