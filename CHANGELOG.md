# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/):
**patch** = fixes and docs, **minor** = new features that don't break anything, **major** = breaking changes.

## [Unreleased]

## [1.0.1] — 2026-11-08
### Changed
- README now shows the openways.ai logo, with light and dark variants.
- The brand is now written as lowercase `openways.ai` everywhere.

## [1.0.0] — 2026-11-08
### Added
- Tool-agnostic Clean Code Agent prompt (`prompt/clean-code-agent.md`) with three modes (`audit`, `safe`, `deep`), a six-phase workflow, an A–K audit checklist, risk levels, and a report template.
- Claude Code plugin `cleancode`, with the `clean-code` subagent and the `/cleancode:clean` skill, plus the `openways` marketplace.
- `scripts/build.sh`, which generates the plugin files from the prompt, and a CI check that keeps them in sync.

[Unreleased]: https://github.com/Maxxoq/cleancode_openways.ai/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/Maxxoq/cleancode_openways.ai/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Maxxoq/cleancode_openways.ai/releases/tag/v1.0.0
