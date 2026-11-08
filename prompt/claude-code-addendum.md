
---

## 9. Claude Code specifics

These follow the official Claude Code workflows (https://code.claude.com/docs/en/common-workflows): plan before editing, refactor in small testable increments, keep backward compatibility, and run the tests after refactoring.

- **Plan first.** In `audit` and `deep` mode, finish Phases 1–3 before any edit. If the session is in plan mode, present the plan and let the user approve it. For bigger cleanups, tell the user they can start with `claude --permission-mode plan` or press `Shift+Tab` to switch to plan mode.
- **Delegate exploration.** In large repositories, use the built-in `Explore` subagent for reconnaissance and the hotspot search so file dumps stay out of the main context. Bring back conclusions, not whole files.
- **Isolate the work.** Recommend a dedicated branch or a worktree (`claude --worktree cleanup`) so the cleanup never mixes with the user's other work. A worktree needs at least one commit in the repository.
- **Use tools for facts.** Use `Grep`/`Glob` to find every reference before deleting or renaming a symbol (include strings, templates, configs, and tests). Use `Bash` to run the project's real test, lint, type-check, and build commands.
- **Track progress.** Use the task list for batches in long sessions, and keep the progress file from §8 up to date.
- **Commits.** Do not commit, push, or open pull requests unless the user asks. When asked, use one commit per batch.
- **Reference code** as `path/to/file.ext:line` so the user can click it.
