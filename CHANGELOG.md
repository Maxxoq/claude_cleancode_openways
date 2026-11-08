# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/):
**patch** = fixes and docs, **minor** = new features that don't break anything, **major** = breaking changes.

## [Unreleased]

## [1.1.0] — 2026-11-08
### Added
- **Challenge step.** Every candidate finding is checked against counter-evidence first: references in strings, configs, entry points, and framework conventions; history and intent; blast radius. It gets a confidence score: 80+ is reported, 50–79 goes to "needs a human decision", lower is dropped. There is also a "do not report" list (style taste, linter-catchable issues, justified suppressions, generated code).
- **`challenger` subagent.** A read-only sceptic that tries to disprove findings and returns CONFIRMED / REFUTED / UNCERTAIN with evidence.
- **`/cleancode:audit` skill.** A truly read-only audit, with `Edit`/`Write`/`NotebookEdit` disabled.
- **Protected-file guard.** A `PreToolUse` hook asks before edits to lockfiles, vendored or generated code, migrations, snapshots, `.env` and build output.
- **Project facts.** A read-only script injected when the skill starts reports the branch, uncommitted changes, git-churn hotspots, tool configs, and package scripts.
- New checklist category **L. AI-generated residue**: swallowed errors reported as success, narrating comments, single-use wrappers, stubs, unexplained lint suppressions. Size signals (function length, nesting, parameters, complexity) are treated as hints, not rules.
- A **red flags** table of common rationalisations, with the reality check for each.
- Stricter **characterization tests**: assert observed literal values, prove each test can fail, and treat a test that cannot run as unverified.
- **Preflight**: the agent lists the commands it will run up front, so you can allow them once.
- Directives 10–11: undo only your own edits (never `git stash` / `reset` / `checkout --` / `restore` / `clean`), and run a scope check after every batch.
- The report now has a verdict, the commands that were run, and a confidence column. The progress file keeps stable finding IDs with status, plus a stop rule against looping.
- `deep` mode offers a minimal option and a thorough option for large structural changes.
- **Evals** (`evals/`): fixture projects with traps and hidden behaviour checks, plus a runner (`all`, single scenario, `recheck`, `selftest`). CI runs the free `selftest`.
- `scripts/release.sh`, and the build now refuses prompt text that Claude Code would execute as a shell command.

### Changed
- Leftover debug output is defined precisely. It is safe to remove even in public functions, but real program output, logging, and tested output are not.
- `diff` scope now means files changed on the current branch compared with the default branch.
- The repository was renamed to `Maxxoq/claude_cleancode_openways`. The old URL redirects.

## [1.0.1] — 2026-11-08
### Changed
- README now shows the openways.ai logo, with light and dark variants.
- The brand is now written as lowercase `openways.ai` everywhere.

## [1.0.0] — 2026-11-08
### Added
- Tool-agnostic Clean Code Agent prompt (`prompt/clean-code-agent.md`) with three modes (`audit`, `safe`, `deep`), a six-phase workflow, an A–K audit checklist, risk levels, and a report template.
- Claude Code plugin `cleancode`, with the `clean-code` subagent and the `/cleancode:clean` skill, plus the `openways` marketplace.
- `scripts/build.sh`, which generates the plugin files from the prompt, and a CI check that keeps them in sync.

[Unreleased]: https://github.com/Maxxoq/claude_cleancode_openways/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Maxxoq/claude_cleancode_openways/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/Maxxoq/claude_cleancode_openways/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Maxxoq/claude_cleancode_openways/releases/tag/v1.0.0
