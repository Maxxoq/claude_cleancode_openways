#!/usr/bin/env bash
# Clean Code Agent — project facts injected into the skill before Claude starts.
# Read-only. Never fails: every probe degrades to a short note.

echo "Working directory: $(pwd)"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Branch: $(git branch --show-current 2>/dev/null || echo '(detached)')"
  echo "Last commit: $(git log -1 --format='%h %s (%cr)' 2>/dev/null || echo 'none yet')"
  changes=$(git status --porcelain 2>/dev/null)
  if [[ -z "$changes" ]]; then
    echo "Working tree: clean"
  else
    echo "Working tree: NOT CLEAN — $(printf '%s\n' "$changes" | wc -l | tr -d ' ') uncommitted path(s):"
    printf '%s\n' "$changes" | head -n 15 | sed 's/^/    /'
  fi
  echo "Hotspots (most changed files in the last year):"
  git log --since="1 year ago" --name-only --format="" 2>/dev/null \
    | grep -v '^$' | sort | uniq -c | sort -rn | head -n 15 | sed 's/^/    /'
  echo "Tracked files: $(git ls-files 2>/dev/null | wc -l | tr -d ' ')"
else
  echo "Version control: not a git repository — changes cannot be reviewed or reverted with git. Warn the user."
fi

echo "Project manifests and tool configs found:"
for f in package.json pnpm-workspace.yaml tsconfig.json pyproject.toml setup.cfg requirements.txt tox.ini \
         pytest.ini Cargo.toml go.mod composer.json Gemfile pom.xml build.gradle build.gradle.kts \
         Makefile justfile .editorconfig .eslintrc.json .eslintrc.js eslint.config.js eslint.config.mjs \
         .prettierrc ruff.toml .golangci.yml phpstan.neon AGENTS.md CLAUDE.md CONTRIBUTING.md; do
  [[ -e "$f" ]] && echo "    $f"
done
if [[ -f package.json ]]; then
  echo "package.json scripts:"
  sed -n '/"scripts"[[:space:]]*:/,/}/p' package.json | sed '1d;$d' | head -n 20 | sed 's/^/    /'
fi
exit 0
