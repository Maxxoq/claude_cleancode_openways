# Clean Code Agent — by OpenWays.ai

A free, open-source **refactoring agent** for Claude Code and any other AI assistant. It goes through your codebase end to end, finds what makes it hard to read, change, and trust, and cleans it up **without changing what it does**.

- **Behaviour first.** It runs your tests, linter, and type checker before and after every batch, and reverts a batch if anything breaks.
- **Small, reviewable steps.** One kind of change per batch, never one giant diff.
- **Your conventions, not its own.** It uses your formatter and linter configs and your naming style.
- **Honest report.** You get a before/after table and a prioritised list of findings with `file:line` locations. Risky things are left for you to decide.

It follows the official Claude Code workflows ([common workflows](https://code.claude.com/docs/en/common-workflows)): plan before editing, refactor in small testable increments, keep backward compatibility, and run the tests.

## Modes

| Mode | What it does |
|---|---|
| `audit` | Read-only. Full report plus a prioritised plan. Changes nothing. |
| `safe` *(default)* | Applies only provably low-risk fixes: dead code, unused imports, debug leftovers, private renames, named constants, guard clauses, your own auto-fixers. |
| `deep` | Shows a plan and waits for your approval, then also does structural refactors batch by batch. |

## Install in Claude Code (plugin)

```bash
claude plugin marketplace add Maxxoq/cleancode_openways.ai
claude plugin install cleancode@openways
```

Then, inside Claude Code:

```text
/cleancode:clean audit            # report only
/cleancode:clean                  # safe mode, whole repo
/cleancode:clean safe src/api     # safe mode, one folder
/cleancode:clean deep diff        # deep mode, only changed files
```

The plugin also adds a **`clean-code` subagent**. Claude can delegate to it on its own, or you can ask: *"use the clean-code agent to tidy up the payments module"*.

**Tips**
- For bigger cleanups, start in plan mode: `claude --permission-mode plan`, or press `Shift+Tab`.
- Work on a separate branch or worktree: `claude --worktree cleanup`. Your repository needs at least one commit for worktrees.
- Commit before you start, so every change is easy to review and revert.

## Install without the plugin system

Copy the files into your user (`~/.claude/`) or project (`.claude/`) folder:

```bash
mkdir -p ~/.claude/agents ~/.claude/skills/clean
BASE=https://raw.githubusercontent.com/Maxxoq/cleancode_openways.ai/main/plugins/cleancode
curl -fsSL "$BASE/agents/clean-code.md"    -o ~/.claude/agents/clean-code.md
curl -fsSL "$BASE/skills/clean/SKILL.md"   -o ~/.claude/skills/clean/SKILL.md
```

Without the plugin namespace, the command is `/clean`.

## Use with other AI tools (ChatGPT, Gemini, Cursor, Copilot, …)

The prompt is tool-agnostic. Use [`prompt/clean-code-agent.md`](prompt/clean-code-agent.md):

- **Chat assistants:** paste it as the system prompt or custom instructions. Then give it your code and say e.g. `mode: audit`.
- **Cursor:** save it as `.cursor/rules/clean-code.mdc`.
- **GitHub Copilot:** reference it from `.github/copilot-instructions.md`, or paste it into chat.
- **Any agent with file and shell access:** use it as the system or task prompt.

Agents that cannot run commands will still produce the audit, but cannot verify changes. Run your tests yourself before you accept their edits.

## Repository layout

```text
prompt/
  clean-code-agent.md        # the prompt — single source of truth, for any AI
  claude-code-addendum.md    # Claude Code-specific additions
plugins/cleancode/           # Claude Code plugin (generated agent + skill)
  .claude-plugin/plugin.json
  agents/clean-code.md
  skills/clean/SKILL.md
.claude-plugin/marketplace.json
scripts/build.sh             # regenerates the plugin files from prompt/
```

## Contributing

Issues and pull requests are welcome, especially real-world cases where the agent did something wrong or missed something.

1. Edit only the files in `prompt/`.
2. Run `./scripts/build.sh` to regenerate the plugin files. CI runs `./scripts/build.sh --check`.
3. Validate with `claude plugin validate ./plugins/cleancode` and `claude plugin validate .`.

## License

[MIT](LICENSE). Free for personal and commercial use.

---

### 🇨🇿 Česky

Bezplatný open-source agent pro čištění a refaktoring kódu od **OpenWays.ai**. Projde celý projekt a vyčistí ho tak, aby se **nezměnilo chování**. Před každou dávkou změn i po ní pouští testy, linter a type-check a dává podrobný report. Instalace a použití jsou popsané výše. Prompt pro ostatní AI je v `prompt/clean-code-agent.md`.
