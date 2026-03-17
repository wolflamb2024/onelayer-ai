---
name: commit
description: Commit staged changes with a well-crafted commit message following project conventions. Use when user asks to "commit", "commit staged changes", "write commit message", or "commit with good message".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Commit Staged Changes

Commit already-staged changes with a well-crafted message following project commit conventions.

## Hard Rules

- **Never** modify, edit, or create any files or code — **except** `go.mod` and `go.sum` when splitting Go module changes into atomic commits (see section 4)
- **Never** push to any remote
- **Never** switch or create branches
- **Never** stage or unstage files — only commit what is already staged
- **Always** present the draft message to the user for approval before committing

## Procedure

### 1. Check preconditions

Run `git diff --cached --stat` to verify there are staged changes. If nothing is staged, tell the user and stop.

### 2. Gather context

Run these in parallel:
- `git diff --cached` — the full staged diff
- `git diff --cached --name-only` — list of changed files
- `git log --oneline -10` — recent commit messages for style reference

### 3. Analyze changes

Read the changed files (using Read tool) as needed to understand the full context of the changes — not just the diff lines but the surrounding code and purpose.

Determine:
- The **primary affected package** (the directory/module most changed)
- **What** changed (the factual delta)
- **Why** it changed (intent, motivation — infer from context)

### 4. Draft the commit message

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
- Each new dependency: `go.mod: get {dependencyPath}` (e.g., `go.mod: get go.onelayer.dev/x/component`)
You may run `go mod init` and `go get` commands to reconstruct these changes step by step, staging and committing after each operation. This is the only case where modifying files is permitted.

**Important:** Never add a Co-Authored-By trailer or any attribution line.

### 5. Present for approval

Show the full draft message to the user. Ask them to approve, edit, or reject it. Wait for their response.

If the user provides edits, incorporate them and re-present. Do not commit until the user explicitly approves.

### 6. Commit

Run `git commit` using HEREDOC format to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<approved message here>
EOF
)"
```

### 7. Verify

Run `git log -1` to confirm the commit succeeded and display the result.
