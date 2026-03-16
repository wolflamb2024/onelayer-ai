---
name: checkout-branch-worktree
description: Set up a git worktree for parallel branch work. Detects git context, asks for project and branch, creates or reuses a worktree, and switches all subsequent work into it. Use when user asks to "work on a branch", "checkout in worktree", "parallel branch", or "worktree checkout".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Checkout Branch in Worktree

Set up an isolated git worktree so all subsequent work happens on a specific branch without affecting the main working tree.

## Hard Rules

- **Never** modify the main working tree or any branch other than the worktree's branch
- **Never** push to any remote
- **Never** delete existing worktrees without explicit user permission
- **All** file paths used after setup must be within the worktree directory
- **Always** confirm the final worktree path to the user before proceeding with any work

## Procedure

### 1. Detect git context

Run `git rev-parse --is-inside-work-tree` to check if the current directory is inside a git repository.

- **If yes** — record the repo root via `git rev-parse --show-toplevel` and skip to **step 3**.
- **If no** — proceed to **step 2**.

### 2. Project selection

List all directories under `./` that contain a `.git` directory:

```bash
for d in ./*/; do [ -d "$d/.git" ] && basename "$d"; done
```

Present the list to the user and ask them to pick one. Once selected, record the repo root as `./<selected>`.

### 3. Ask for branch name

Ask the user for the branch name they want to work on. Accept the name exactly as given.

### 4. Check branch existence

Run these in parallel from the repo root:

- `git branch --list <branch>` — check local branches
- `git branch -r --list "*/<branch>"` — check remote branches
- `git worktree list` — check existing worktrees

Determine:

- Does the branch exist locally?
- Does the branch exist on a remote only?
- Is the branch entirely new?
- Is there already a worktree for this branch?

### 5. Create or reuse worktree

The worktree path is `<repo-root>/.worktrees/<branch-name>/`.

**If a worktree already exists for this branch:** inform the user and reuse it. Skip creation.

**If the branch exists locally:**

```bash
git worktree add <worktree-path> <branch>
```

**If the branch exists on a remote only:**

```bash
git worktree add -b <branch> <worktree-path> <remote>/<branch>
```

Use the remote name from the `git branch -r` output (typically `origin`).

**If the branch is new:**

```bash
git worktree add -b <branch> <worktree-path>
```

### 6. Switch working directory

Change into the worktree directory:

```bash
cd <worktree-path>
```

From this point forward, **all file operations and AI changes must use paths within the worktree directory exclusively**. The main working tree is off-limits.

### 7. Confirm setup

Run these in parallel from the worktree:

- `git status`
- `git log --oneline -1`
- `pwd`

Present the results to the user:

- The absolute worktree path
- The current branch and latest commit
- A reminder that all changes are isolated to this worktree and will not affect the main working tree
