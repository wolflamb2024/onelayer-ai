---
name: interactive-commit
description: Interactive multi-commit session. Loops through stage-commit cycles with user control. Use when user asks to "interactively commit", "commit multiple times", "multi-commit session", or "commit in a loop".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Interactive Commit Session

An interactive loop that repeats the commit workflow for multiple rounds. The user stages changes between iterations; you draft and commit each round following project conventions.

## Hard Rules

- **Never** modify, edit, or create any files or code — **except** `go.mod` and `go.sum` when splitting Go module changes into atomic commits (see section 5)
- **Never** push to any remote
- **Never** switch or create branches
- **Never** stage or unstage files — only commit what is already staged
- **Always** present the draft message to the user for approval before committing
- **Always** verify that project builds successfully after each commit

## Procedure

### 1. Start the session

Announce the start of an interactive commit session. Explain that the user should stage changes before each round and that you will loop until they say they are done.

### 2. Check for staged changes

Run `git diff --cached --stat` to verify there are staged changes.

If nothing is staged, tell the user to stage their changes and **wait** for them to confirm they have done so. Do not proceed until staged changes exist.

### 3. Gather context

Run these in parallel:
- `git diff --cached` — the full staged diff
- `git diff --cached --name-only` — list of changed files
- `git log --oneline -10` — recent commit messages for style reference

### 4. Analyze changes

Read the changed files (using Read tool) as needed to understand the full context of the changes — not just the diff lines but the surrounding code and purpose.

Determine:
- The **primary affected package** (the directory/module most changed)
- **What** changed (the factual delta)
- **Why** it changed (intent, motivation — infer from context)

### 5. Draft the commit message

Follow these conventions exactly:

**First line:** `<package>: <summary>`
- Lowercase start (no capital after the colon)
- No trailing period
- Short — completes the sentence "This change modifies package `<package>` to ___"
- Use a verb that describes the **functional result**, not the mechanical file operation (e.g., "fix", "document", "support", "improve")
- Prefer functional verbs: `topology: document go package` NOT `topology: add package documentation`

**Blank line**

**Body:**
- Complete sentences with correct punctuation
- Explain **what** changed and **why**
- No Markdown, no HTML — plain text only
- Add relevant details (e.g., benchmark data, algorithm references) when useful

**go.mod / go.sum commits:**
When the staged changes include `go.mod` or `go.sum`, split them into separate atomic commits — one per logical operation:
- Module initialization: `go.mod: init {modulePath}` (e.g., `go.mod: init go.onelayer.dev/x/topology`)
- Each new dependency group: `go.mod: get {dependencyPath}` (e.g., `go.mod: get go.onelayer.dev/x/component`)
You may run `go mod init` and `go get` commands to reconstruct these changes step by step, staging and committing after each operation. This is the only case where modifying files is permitted.

**Important:** Never add a Co-Authored-By trailer or any attribution line.

### 6. Present for approval

Show the full draft message to the user. Ask them to approve, edit, or reject it. Wait for their response.

If the user provides edits, incorporate them and re-present. Do not commit until the user explicitly approves.

### 7. Commit

Run `git commit` using HEREDOC format to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<approved message here>
EOF
)"
```

### 8. Verify

Run `git log -1` to confirm the commit succeeded and display the result.

### 9. Continue or finish

Ask the user: **"Do you want to stage more changes and commit again, or are we done?"**

- If the user wants to continue → go back to **step 2**.
- If the user is done → go to **step 10**.

### 10. Session summary

Show a summary of all commits made during this session:

```bash
git log --oneline -<N>
```

Where `<N>` is the number of commits created in this session. Present the list and confirm the session is complete.
