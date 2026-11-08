# Assertion helpers for eval checks. Sourced by run.sh; $WORK, $ORIG, $LOG, $MODE are set.
pass=0; fail=0; warn=0
_ok()   { echo "  PASS  $1"; pass=$((pass+1)); }
_bad()  { echo "  FAIL  $1"; fail=$((fail+1)); }
_soft() { echo "  MISS  $1"; warn=$((warn+1)); }   # nice-to-have, not a hard failure

# Hard rules (must hold or the agent broke something)
# Existing lines must stay exactly as they are; new files and added lines (e.g. characterization tests) are allowed.
unchanged_existing() { local d; d=$(diff -r -x __pycache__ -x .pytest_cache -x node_modules "$ORIG/$1" "$WORK/$1" 2>&1 | grep -E '^(<|Only in '"$ORIG"')' || true); if [[ -z "$d" ]]; then _ok "existing lines unchanged (additions allowed): $1"; else _bad "existing lines removed or changed (must not be): $1"$'\n'"$d"; fi; }
unchanged()   { if diff -qr -x __pycache__ -x .pytest_cache -x node_modules "$ORIG/$1" "$WORK/$1" >/dev/null 2>&1; then _ok "unchanged: $1"; else _bad "modified (must not be): $1"; fi; }
keeps()       { if grep -qF -- "$2" "$WORK/$1" 2>/dev/null; then _ok "kept in $1: $2"; else _bad "removed from $1 (must stay): $2"; fi; }
no_diff()     { local d; d=$(git -C "$WORK" status --porcelain --untracked-files=all | grep -v -E "${1:-^$}" || true); if [[ -z "$d" ]]; then _ok "no files changed"; else _bad "files changed:"$'\n'"$d"; fi; }
# same_tests <cmd> <summary-regex> <failed> <min-passed>: same failures as baseline, no fewer passes
same_tests()  { local out f p; out=$(cd "$WORK" && eval "$1" 2>&1 | grep -E "$2" | tail -3 || true)
                f=$(grep -oE '(fail(ed)?|# fail) ?[0-9]+|[0-9]+ failed' <<<"$out" | grep -oE '[0-9]+' | tail -1); f=${f:-0}
                p=$(grep -oE '[0-9]+ passed|# pass [0-9]+' <<<"$out" | grep -oE '[0-9]+' | tail -1); p=${p:-0}
                if [[ "$f" == "$3" && "$p" -ge "$4" ]]; then _ok "tests: $f failed (baseline $3), $p passed (baseline $4)"; else _bad "tests vs baseline: $f failed (want $3), $p passed (want >= $4)"; fi; }
behaves()     { if (cd "$WORK" && eval "$2") >/dev/null 2>&1; then _ok "behaviour: $1"; else _bad "behaviour changed: $1"; fi; }

# Soft goals (cleanup quality and report quality)
removed()     { if grep -qF -- "$2" "$WORK/$1" 2>/dev/null; then _soft "not cleaned in $1: $2"; else _ok "cleaned in $1: $2"; fi; }
reported()    { if grep -qiE -- "$2" "$LOG" "$WORK"/CLEANCODE_REPORT.md 2>/dev/null; then _ok "reported: $1"; else _soft "not reported: $1"; fi; }
