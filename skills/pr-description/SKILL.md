---
name: pr-description
description: Construct a PR title and description following project conventions. Use when user asks to "write PR description", "create PR description", "draft PR", "PR title", or "describe this PR".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Construct PR Description

Draft a pull request title and description following OneLayer PR conventions.

## Hard Rules

- **Never** modify, edit, or create any source files
- **Never** push, commit, or switch branches
- **Never** create the PR on GitHub — only draft the text
- **Always** present the draft to the user for approval before doing anything with it

## Procedure

### 1. Determine branch and base

Run these in parallel:

- `git rev-parse --abbrev-ref HEAD` — current branch name
- `git log --oneline main..HEAD` — commits on this branch (try `main`, fallback to `master`)
- `git diff main..HEAD --stat` — file-level change summary

If the branch is `main` or `master`, tell the user there is nothing to describe and stop.

### 2. Gather full context

Run these in parallel:

- `git diff main..HEAD` — full diff against base
- `git diff main..HEAD --name-only` — changed file list
- `git log main..HEAD --format="%h %s%n%n%b"` — full commit messages with bodies

Read changed files as needed (using Read tool) to understand the purpose and motivation behind the changes — not just what changed but why.

### 3. Analyze

From the commits, diff, and file context determine:

- **What** changed — the factual delta across all commits
- **Why** it changed — the motivation, problem being solved, or feature being added
- Relevant issues, PRs, or external resources mentioned in commits or code comments

### 4. Draft the title

Follow these rules exactly:

- **Short** — under 72 characters
- **Present tense, imperative mood** — completes the sentence "This PR will ___"
- **Grammatically correct English sentence** — not a book title, not a branch name
- Use a verb that describes the functional outcome:
  - "Fix bug with the login page" not "Fixed bug with the login page"
  - "Add new dashboard feature" not "Adding new dashboard feature"
  - "Support data isolation between network-twins" not "Data isolation for the network-twin"

### 5. Draft the description

Follow these rules exactly:

- **Brief summary** of what changed and **why**
- **Active voice** throughout
- **Include relevant links** to issues, other PRs, or external resources when available
- Write in flowing prose — well-constructed sentences and paragraphs, not just bullet dumps
- The description becomes the commit message body when merged, so keep it meaningful as plain text (Markdown is fine but remember git renders it as plain text)
- Do not add Co-Authored-By trailers or attribution lines

### 6. Present for approval

Show the full draft (title + description) to the user formatted as:

```
Title: <title>

Description:
<description>
```

Ask the user to approve, edit, or reject. Wait for their response. If the user provides edits, incorporate them and re-present. Do not proceed until the user explicitly approves.

### 7. Offer next steps

After approval, ask the user if they want to:

1. Copy the text (just confirm it is ready)
2. Create the PR on GitHub using `gh pr create` with the approved title and description
