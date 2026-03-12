# onelayer-ai

Shared AI coding assistant skills and rules for the OneLayer team. This repo is the single source of truth — edit here, install everywhere.

## What's inside

**Skills** — reusable slash-command workflows for AI coding assistants:

- `commit` — Commits staged changes with a well-crafted message following OneLayer commit conventions. Invoked with `/commit`.
- `restructure-commits` — Reorganizes messy commits into clean, atomic, convention-following commits on a new branch. Invoked with `/restructure-commits`.

**Rules** — coding and workflow conventions loaded as persistent context:

- `commits.md` — Commit structure, atomicity, message format.
- `working_guide.md` — Issue types, branch naming, PR conventions, commit ordering.
- `coding_style.md` — Go coding style rules (naming, error handling, testing, imports, etc.).

## Repository structure

```
onelayer-ai/
├── skills/
│   ├── commit/
│   │   └── SKILL.md
│   └── restructure-commits/
│       └── SKILL.md
├── rules/
│   ├── commits.md
│   ├── working_guide.md
│   └── coding_style.md
├── install-skills.sh
└── README.md
```

## Installation

Clone the repo and run the install script:

```bash
git clone <repo-url> ~/code/onelayer-ai
cd ~/code/onelayer-ai
./install-skills.sh
```

This copies skills and rules to all four supported tool config directories:

| Tool | Config directory | Skills format | Rules directory |
|------|-----------------|---------------|-----------------|
| Claude Code | `~/.claude` | `skills/<name>/SKILL.md` | `~/.claude/rules/` |
| Codex CLI | `~/.codex` | `skills/<name>/SKILL.md` | `~/.codex/rules/` |
| OpenCode | `~/.config/opencode` | `commands/<name>.md` | `~/.config/opencode/rules/` |
| .ai (legacy) | `~/.ai` | `commands/<name>.md` | `~/.ai/rules/` |

The script is idempotent — run it again after pulling updates to refresh all targets.

### Testing without touching real config

Use the `--root` flag to install to a custom prefix:

```bash
./install-skills.sh --root /tmp/test-install
```

This creates the same directory structure under `/tmp/test-install/` instead of `~/`, so you can inspect the output without affecting your real configuration.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with the skill content.
2. If the skill references config-relative paths (like rules files), use `{{CONFIG_DIR}}` as a placeholder. The install script replaces it with the correct path for each tool (e.g., `~/.claude` for Claude Code, `~/.config/opencode` for OpenCode).
3. Run `./install-skills.sh` to deploy.

## Adding a new rule

1. Add the `.md` file to `rules/`.
2. Run `./install-skills.sh` to deploy.

## Updating

After editing any skill or rule in this repo:

```bash
./install-skills.sh
```

That's it. All four tool configs are refreshed with the latest versions.
