---
name: restructure-commits
description: Restructure messy git commits into clean, atomic, convention-following commits ready for PR. Use when user asks to "restructure commits", "clean up commits", "rewrite history", or "prepare commits for PR".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Restructure Commits

Reorganize the current branch's commits into clean, atomic, convention-following commits on a new branch. The original branch is never modified and serves as the backup.

## Hard Rules

1. **Never modify file contents** — only rearrange existing changes into new commits. **Exception:** you may run `go mod init` and `go get` to reconstruct `go.mod` / `go.sum` changes as separate atomic commits.
2. **Never push.** This skill only creates local commits.
3. **Never run tests or builds.** The goal is purely git history rewriting.
4. **Never delete or force-modify the original branch.** It stays untouched.
5. **Only use read-only tools + Bash for git and Go module commands.** No Write or Edit tools — except that Bash may run `go mod init` and `go get` to split module changes.
6. **Always** verify that project builds successfully after each commit

## Conventions

Follow the commit message format, atomicity rules, and ordering conventions defined in:
- `{{CONFIG_DIR}}/rules/commits.md` — commit structure, atomicity, message format
- `{{CONFIG_DIR}}/rules/working_guide.md` — branch naming (prefixes, kebab-case, lowercase), commit ordering, PR conventions

Key commit message format reminder:
- First line: `<package>: <summary>` — completes "This change modifies package X to ___"
- Lowercase start, no period, no complete sentence on first line
- Blank line, then body with complete sentences explaining what and why
- Use functional verbs that describe the result, not the file operation: `topology: document go package` NOT `topology: add package documentation`

## Phase 1: Setup

1. Record the current branch name as `ORIGINAL_BRANCH`:
   ```
   git rev-parse --abbrev-ref HEAD
   ```
2. Verify there are commits ahead of main:
   ```
   git log main..HEAD --oneline
   ```
   If no commits exist ahead of main, stop and inform the user.
3. Verify working tree is clean:
   ```
   git status --porcelain
   ```
   If dirty, stop and ask user to commit or stash changes first.
4. Ask the user for a new branch name. Suggest one based on the changes you'll analyze in Phase 2 (so do a quick look at changed files first). Offer prefix options: `feature/`, `bugfix/`, `docs/`, `experiment/`, `refactor/`. The name must be kebab-case and lowercase per conventions.

## Phase 2: Analysis

1. Get the high-level picture:
   ```
   git diff main..HEAD --stat
   git diff main..HEAD --name-only
   ```
2. Get the full diff:
   ```
   git diff main..HEAD
   ```
3. Read each changed file in full using the Read tool to understand the logical structure, package boundaries, type definitions, and how pieces connect.
4. Identify Go packages affected. Group files into logical atomic commit units where each unit:
   - Belongs to a single package (or tightly coupled cross-package change)
   - Is self-contained: the codebase compiles after applying this commit
   - Includes both implementation and its tests together (never separate them)

## Phase 3: Propose Commit Plan

Present a numbered list of proposed commits. For each commit show:
- **Files**: which files are included
- **Commit message**: full message (first line + body)
- **Rationale**: why this is one atomic unit

### Commit Ordering Principles

Order commits to tell the story of the feature layer by layer:

1. **go.mod / go.sum** — dependency changes first, split into one commit per operation:
   - `go.mod: init {modulePath}` for module initialization
   - `go.mod: get {dependencyPath}` for each new dependency group (one commit per dependency group)
   To produce these commits, run `go mod init` and individual `go get` commands, staging and committing after each.
2. **doc.go / types / interfaces** — package documentation and type definitions
3. **Implementation + tests** — core logic with its tests (same commit per package)
4. **Server / API / handlers** — integration layer
5. **Wiring / main / cmd** — connecting everything together
6. **Tooling / config / CI** — supporting files

Within the same layer, order by dependency: if package A imports package B, commit B first.

Present the full plan and ask the user for approval before proceeding. Accept feedback and revise if needed.

## Phase 4: Execute

1. Create the new branch from main:
   ```
   git checkout -b <new-branch> main
   ```
   If the branch name already exists, stop and ask the user for an alternative name.

2. For each commit in the approved plan, in order:
   ```
   git checkout <ORIGINAL_BRANCH> -- <file1> <file2> ...
   git add <file1> <file2> ...
   git commit -m "$(cat <<'EOF'
   <package>: <summary>

   <body>
   EOF
   )"
   ```

3. After all commits are created, switch back but do NOT delete or modify the original branch:
   ```
   git checkout <new-branch>
   ```

## Phase 5: Verify

1. Verify the final state matches the original branch exactly:
   ```
   git diff <ORIGINAL_BRANCH>..<new-branch>
   ```
   This diff MUST be empty. If not, something went wrong — investigate and fix.

2. Show the new commit history:
   ```
   git log main..<new-branch> --stat
   ```

3. Report the result to the user:
   - Number of commits created
   - New branch name
   - Reminder that nothing was pushed
   - Reminder that the original branch (`ORIGINAL_BRANCH`) is still intact

## Edge Cases

- **Main has diverged**: If `git merge-base main HEAD` differs from `main`, warn the user and suggest rebasing the original branch onto main first.
- **Branch name conflict**: If the suggested branch name already exists, ask for an alternative.
- **Single file change**: Still follow the same process; a single commit is fine when appropriate.
- **Binary files**: Include them in the appropriate commit but note them in the plan.
- **go.mod/go.sum changes**: These must be split into one commit per `go mod init` and one commit per `go get` dependency, using the `go.mod: init ...` / `go.mod: get ...` naming convention.
