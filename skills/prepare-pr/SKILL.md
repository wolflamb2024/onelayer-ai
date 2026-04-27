---
name: prepare-pr
description: Orchestrate a full PR preparation pipeline — review code, document exported functions, and draft PR description. Use when user asks to "prepare PR", "prepare pull request", "get branch ready for PR", or "prep PR".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Write, Edit, Skill
---

# Prepare PR

Orchestrate a full pull request preparation: review changes against style rules, add missing doc comments for new exported functions, and draft a PR description — stopping early if the review surfaces critical or warning findings.

## Hard Rules

1. **Only modify source code files to add missing doc comments above exported functions/methods.**
2. **Never push, commit, or switch branches.**
3. **If review has critical or warning findings, do NOT proceed to PR description.**

## Procedure

### 1. Determine branch and base

Run these in parallel:

- `git rev-parse --abbrev-ref HEAD` — current branch name
- `git log --oneline main..HEAD` — commits on this branch (try `main`, fallback to `master`)
- `git diff main..HEAD --stat` — file-level change summary

If the branch is `main` or `master`, tell the user there is nothing to prepare and stop.
If there are no commits ahead of `main`, tell the user the branch has no new work and stop.

### 2. Invoke `/review-changes`

Call the `review-changes` skill to review code against OneLayer style rules. This produces `review.md` in the repository root.

Wait for the skill to complete before continuing.

### 3. Add doc comments for new exported functions/methods

Get the changed file list:

- `git diff main..HEAD --name-only`

For each changed `.go` file, skip files that are:
- Test files (`_test.go`)
- Generated files (contain `// Code generated`)
- Vendored files (`vendor/`)

For each remaining `.go` file, examine the diff (`git diff main..HEAD -- <file>`) and identify all **new exported functions and methods** (present in `+` lines of the diff). An exported function or method starts with an uppercase letter.

For each new exported function or method found, read the source file and check whether it already has a doc comment directly above it. If it does, skip it. If it does not, add a Go doc comment directly above the function/method declaration in the source file.

The doc comment must follow Go conventions:
- Start with the function/method name (e.g., `// FuncName does ...`)
- Be concise (1-3 sentences)
- Explain what the function does, not how

Do not create any separate documentation files. Do not modify anything else in the source files.

### 4. Evaluate review results

Read `review.md` and check for findings:

- If there are any **critical** or **warning** findings, present them to the user and **stop**. Tell the user the review found issues that should be addressed before drafting a PR description.
- If there are only **suggestion** findings or no findings at all, proceed to step 5.

### 5. Invoke `/pr-description`

Call the `pr-description` skill to draft the PR title and description. That skill handles presenting the draft to the user for approval and offering to create the PR.
