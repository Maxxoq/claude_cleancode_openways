<p align="center">
  <a href="https://openways.ai">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="assets/openways-logo-dark.svg">
      <img src="assets/openways-logo-light.svg" alt="openways.ai" width="320">
    </picture>
  </a>
</p>

# Clean Code Agent — by openways.ai

A free, open-source **refactoring agent** for Claude Code and any other AI assistant. It goes through your codebase end to end, finds what makes it hard to read, change, and trust, and cleans it up **without changing what it does**.

- **Behaviour first.** It runs your tests, linter, and type checker before and after every batch, and undoes a batch if anything breaks. It never weakens a test to make it pass.
- **Findings it can defend.** Every candidate is challenged before it is reported: the agent tries to prove itself wrong (dynamic imports, entry points, framework conventions, callers that rely on odd behaviour) and scores its confidence. Weak findings go to "needs a human decision" or are dropped.
- **Guard rails, not just words.** The read-only audit has editing tools switched off. A hook asks you before any edit to lockfiles, vendored or generated code, migrations, snapshots, or `.env` files.
- **Small, reviewable steps.** One kind of change per batch, a scope check after each, never one giant diff.
- **Catches AI residue too.** Errors swallowed and reported as success, narrating comments, pointless wrappers, placeholder stubs.
- **Honest report.** A verdict, a before/after table with the exact commands that were run, and prioritised findings with `file:line`, confidence, and risk.

It follows the official Claude Code workflows ([common workflows](https://code.claude.com/docs/en/common-workflows)): plan before editing, refactor in small testable increments, keep backward compatibility, and run the tests.

## Modes

| Mode | What it does |
|---|---|
| `audit` | Read-only. Full report plus a prioritised plan. Changes nothing. |
| `safe` *(default)* | Applies only provably low-risk fixes: dead code, unused imports, debug leftovers, private renames, named constants, guard clauses, your own auto-fixers. |
| `deep` | Shows a plan and waits for your approval, then also does structural refactors batch by batch, with characterization tests for untested code. |

## Install in Claude Code (plugin)

```bash
claude plugin marketplace add Maxxoq/claude_cleancode_openways
claude plugin install cleancode@openways
```

Then, inside Claude Code:

```text
/cleancode:audit                  # read-only report (editing tools are off)
/cleancode:audit src/api          # audit one folder
/cleancode:clean                  # safe mode, whole repo
/cleancode:clean safe src/api     # safe mode, one folder
/cleancode:clean deep diff        # deep mode, only files changed on this branch
```

| Component | What it is |
|---|---|
| `/cleancode:clean` skill | The agent in `safe` or `deep` mode (`audit` also works). |
| `/cleancode:audit` skill | The agent in `audit` mode with `Edit`/`Write` disabled. |
| `clean-code` subagent | The same agent, for delegation: *"use the clean-code agent to tidy up the payments module"*. |
| `challenger` subagent | A read-only sceptic that tries to disprove findings and returns CONFIRMED / REFUTED / UNCERTAIN with evidence. |
| Protected-file guard | A `PreToolUse` hook, active once you run one of the skills. It asks before edits to lockfiles, vendored/generated code, migrations, snapshots, and `.env` files. |
| Project facts | When a skill starts, a read-only script collects the branch, uncommitted changes, change hotspots, and the project's tool configs. |

**Tips**
- Start with `/cleancode:audit`. It changes nothing and shows you what the agent would do.
- Commit before you start, so every change is easy to review and revert. The agent refuses to edit a repository with uncommitted changes.
- For bigger cleanups, start in plan mode: `claude --permission-mode plan`, or press `Shift+Tab`.
- Work on a separate branch or worktree: `claude --worktree cleanup`. Your repository needs at least one commit for worktrees.

## Try it without installing

```bash
git clone https://github.com/Maxxoq/claude_cleancode_openways.git
cd your-project
claude --plugin-dir ../claude_cleancode_openways/plugins/cleancode
```

## Use with other AI tools (ChatGPT, Gemini, Cursor, Copilot, …)

The prompt is tool-agnostic. Use [`prompt/clean-code-agent.md`](prompt/clean-code-agent.md):

- **Chat assistants:** paste it as the system prompt or custom instructions. Then give it your code and say e.g. `mode: audit`.
- **Cursor:** save it as `.cursor/rules/clean-code.mdc`.
- **GitHub Copilot:** reference it from `.github/copilot-instructions.md`, or paste it into chat.
- **Any agent with file and shell access:** use it as the system or task prompt. [`prompt/challenger.md`](prompt/challenger.md) works as a second, sceptical reviewer.

Agents that cannot run commands will still produce the audit, but cannot verify changes. Run your tests yourself before you accept their edits.

## Evals

The agent is tested against fixture projects full of traps (`evals/`). Each fixture has real mess to clean up next to code that only *looks* removable or changeable, such as functions called by name, entry points declared in config, pytest fixtures, loose equality that callers rely on, error messages that scripts grep for, and generated and vendored files. **Hidden behaviour checks** that the agent never sees verify that nothing changed.

Results for v1.1.0 (Claude Code 2.1.319, default model, 2026-11-08):

| Scenario | What it checks | Result |
|---|---|---|
| `py-shop` audit | Nothing changes; secrets, SQL injection, swallowed errors, mutable defaults, and duplication are reported | 28 / 28 |
| `py-shop` safe | Dead code removed; dynamic handlers, entry points, fixtures, public API, generated and vendored files, and grepped messages untouched; hidden behaviour checks | 34 / 34 |
| `py-shop` deep | Same as safe, plus approved structural refactors and added characterization tests; existing tests only grow | 34 / 34 |
| `py-shop` dirty tree | Refuses to edit when there are uncommitted changes | 3 / 3 |
| `js-cart` audit | Nothing changes; loose equality and dynamic `require` are recognised as intentional | 11 / 11 |
| `js-cart` safe | Dead code and debug output removed; `==` semantics, dynamic plugins, and the generated schema untouched | 16 / 16 |

Evals are a regression net, not a guarantee. Model output varies from run to run, and real projects are messier than fixtures. Review the diff before you commit.

Run them yourself (this uses your Claude Code subscription or API credits):

```bash
./evals/run.sh all                 # every scenario
./evals/run.sh py-shop deep        # one fixture, one mode
```

## Repository layout

```text
prompt/
  clean-code-agent.md        # the prompt — single source of truth, for any AI
  challenger.md              # the sceptical second reviewer
  claude-code-addendum.md    # Claude Code-specific additions
plugins/cleancode/           # Claude Code plugin
  .claude-plugin/plugin.json
  agents/                    # generated: clean-code.md, challenger.md
  skills/                    # generated: clean/SKILL.md, audit/SKILL.md
  scripts/guard.sh           # protected-file hook
  scripts/context.sh         # project facts for the skills
.claude-plugin/marketplace.json
evals/                       # fixtures with traps, runner, checks
scripts/build.sh             # regenerates agents and skills from prompt/
scripts/release.sh           # tags and publishes a version from CHANGELOG.md
assets/                      # openways.ai logo
```

## Contributing

Issues and pull requests are welcome, especially real-world cases where the agent did something wrong or missed something.

1. Edit the files in `prompt/` (and `plugins/cleancode/scripts/` for the hook and context scripts). Never edit the generated agents and skills by hand.
2. Run `./scripts/build.sh` to regenerate the plugin files. CI runs `./scripts/build.sh --check`.
3. Validate with `claude plugin validate ./plugins/cleancode` and `claude plugin validate .`.
4. For behaviour changes, run the evals (`./evals/run.sh all`), and add a fixture or check for the case you are fixing.
5. Add a line under `[Unreleased]` in [CHANGELOG.md](CHANGELOG.md).

**Releases** follow [Semantic Versioning](https://semver.org/). Maintainers bump `version` in `plugins/cleancode/.claude-plugin/plugin.json`, then turn `[Unreleased]` into a dated version section and commit. After that, `./scripts/release.sh` tags the commit, pushes it, and creates the GitHub release. Users update with `claude plugin marketplace update openways` and then `claude plugin update cleancode@openways`.

## License

[MIT](LICENSE). Free for personal and commercial use.

---

### 🇨🇿 Česky

Bezplatný open-source agent pro čištění a refaktoring kódu od **openways.ai**. Projde celý projekt a vyčistí ho tak, aby se **nezměnilo chování**. Každé zjištění si nejdřív sám zkusí vyvrátit, před každou dávkou změn i po ní pouští testy, linter a type-check a chráněné soubory (lockfiles, generovaný a vendorovaný kód, migrace, `.env`) bez tvého souhlasu nezmění. Nakonec dá podrobný report. Instalace a použití jsou popsané výše. Prompt pro ostatní AI je v `prompt/clean-code-agent.md`.
