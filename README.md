# onelayer-ai

Shared AI coding assistant skills and rules for the OneLayer team. This repo is the single source of truth — edit here, install everywhere.

## What's inside

**Skills** — slash-command workflows that handle git commits following OneLayer conventions. All commit messages use the `<package>: <summary>` format, enforce atomicity, and follow the rules defined in `rules/commits.md` and `rules/working_guide.md`.

**Rules** — coding and workflow conventions loaded as persistent context (see [Rules](#rules) below).

## Skills

### `/commit` — Commit staged changes

Use when you have already staged files (`git add`) and want to create a single, well-crafted commit. The assistant analyzes the staged diff, reads surrounding code for context, drafts a commit message following OneLayer conventions, and presents it for your approval before committing. Nothing is pushed, no files are modified — it only commits what you staged.

**When to use:** You are building a PR commit by commit, staging changes yourself, and want each commit message written properly.

### `/interactive-commit` — Multi-commit session

Same as `/commit`, but runs in a loop. After each commit you can stage more changes and commit again, or end the session. At the end it shows a summary of all commits created.

**When to use:** You have multiple logical changes to commit in one sitting and want to go through them one by one without re-invoking the skill each time.

### `/restructure-commits` — Clean up a messy branch

Use when your branch has messy, unstructured commits and you want to reorganize them into clean, atomic commits on a new branch. The assistant analyzes all changes between `main` and `HEAD`, proposes a commit plan (grouped by package, ordered layer by layer), and after your approval creates a new branch with the restructured commits. The original branch is never modified — it stays as your backup.

**When to use:** You finished the work but your commit history is rough — WIP commits, mixed concerns, wrong ordering. You want a clean history before opening a PR.

### `/checkout-branch-worktree` — Work on a branch in an isolated worktree

Use when you want to switch to a branch without affecting your main working tree. The assistant detects the git context, asks for the branch name, creates (or reuses) a worktree under `.worktrees/<branch>/`, and switches all subsequent work into it. Supports local branches, remote-only branches, and entirely new branches. Nothing is pushed — the worktree is purely local.

**When to use:** You want to work on a different branch in parallel, review someone else's branch, or start a new feature without disturbing your current checkout.

### `/interactive-restructure-commits` — Clean up with full control

Same as `/restructure-commits`, but gives you more control during execution. After the commit plan is proposed, you can choose to:

1. **Approve all at once** — execute the entire plan.
2. **Modify the plan** — revise grouping, ordering, or messages before execution.
3. **Commit-by-commit mode** — review and approve (or edit/skip) each commit individually as it is created.

**When to use:** Same situation as `/restructure-commits`, but you want to inspect or adjust each commit before it lands.

## Rules

Rules are loaded as persistent context into your AI coding assistant. They define OneLayer conventions:

- `commits.md` — Commit structure, atomicity, message format.
- `working_guide.md` — Issue types, branch naming, PR conventions, commit ordering.
- `coding_style.md` — Go coding style rules (naming, error handling, testing, imports, etc.).

## Repository structure

```
onelayer-ai/
├── skills/
│   ├── commit/
│   │   └── SKILL.md
│   ├── interactive-commit/
│   │   └── SKILL.md
│   ├── interactive-restructure-commits/
│   │   └── SKILL.md
│   ├── restructure-commits/
│   │   └── SKILL.md
│   └── checkout-branch-worktree/
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
