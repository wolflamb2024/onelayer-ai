---
name: review-changes
description: Review code changes against OneLayer Go style rules and flag bugs, logic errors, race conditions, and security issues. Use when user asks to "review changes", "review code", "review my branch", "check style", or "code review".
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Write
---

# Review Changes

Review code changes against OneLayer Go style and engineering quality rules, then write a structured `review.md` report in the repository root.

## Hard Rules

1. **Never modify source code files.**
2. **Never push, commit, or switch branches.**
3. **Only write one file:** `review.md` in the repository root.
4. **Always read the full rules files before analyzing code:**
   - `{{CONFIG_DIR}}/rules/coding_style.md`
   - `{{CONFIG_DIR}}/rules/style_guide.md`

## Procedure

### 1. Determine Scope

Detect review mode in this order:

1. **Staged changes** if `git diff --cached --name-only` is non-empty.
2. **Unstaged changes** if `git diff --name-only` is non-empty.
3. **Branch diff** otherwise, using merge-base against `main`:
   - Try `main` first.
   - If `main` does not exist, fallback to `master`.
   - Use `git merge-base <base> HEAD` and review `<merge-base>..HEAD`.

Handle detached HEAD:
- If `git rev-parse --abbrev-ref HEAD` returns `HEAD`, record short SHA via `git rev-parse --short HEAD` and include it in the report context.

If no changes are found in any mode, report "No changes to review" and stop.

### 2. Gather Changes

For the selected mode, run these in parallel:

- Full diff (`git diff ...`)
- Changed file list (`git diff ... --name-only`)
- Diff stats (`git diff ... --stat`)

Use the mode-specific diff target:

- Staged: `git diff --cached`
- Unstaged: `git diff`
- Branch: `git diff <merge-base>..HEAD`

If diff includes 30+ files, prioritize deeper analysis by highest-change files from `--stat`, then cover remaining files with lighter pass.

### 3. Read Context

1. Read both rule files in full:
   - `{{CONFIG_DIR}}/rules/coding_style.md`
   - `{{CONFIG_DIR}}/rules/style_guide.md`
2. Read every changed file in full using Read.
3. Skip:
   - Generated files (`// Code generated`)
   - Vendored files (`vendor/`)
   - Binary/non-text files
4. Identify for each changed Go file:
   - Package name
   - Whether it is a test file
   - Imports and grouping
   - Exported symbols touched

If no Go files changed, skip Go-specific rule checks and note that in the final summary.

### 4. Analyze

Apply all rules from both style documents and perform general code review checks.

Categories to evaluate:

- Naming: MixedCaps, avoid `Get` prefix, avoid repetition, avoid shadowing
- Error handling: `errors.Is/As`, `%w` placement, avoid duplicated wrapping/logging, avoid double-logging
- Imports: stdlib -> external -> internal grouping order
- Documentation: explain why (not only what), signal boosting, cleanup docs
- Testing: table-driven tests, no assertion libraries, use `cmp`, `t.Helper()`, no `t.Fatal` from goroutines
- Variables: `:=` vs `var`, composite literals, channel direction clarity
- API design: option structs when appropriate, `context.Context` placement
- Global state: prefer DI over mutable package-level state
- Panics: only for API misuse/invariant violations
- String building: use the right string construction tool for workload
- Package structure: domain cohesion, test double naming clarity
- Bugs: nil dereference risk, off-by-one, loop variable capture, missing boundary checks
- Race conditions: shared mutable state without synchronization
- Security: injection risk, hardcoded credentials/secrets, unsafe input handling
- Resource management: unclosed resources, missing `defer`, missing context propagation
- Dead code: unused code paths, stale commented-out code

Severity levels:

- `critical`: merge blockers
- `warning`: should fix
- `suggestion`: nice to have

Also handle these edge cases:

- Deleted or renamed files: check for stale references and call out likely breakage
- Large diffs: focus deepest on files with highest churn first
- Detached HEAD: use commit SHA in report context

### 5. Generate `review.md`

Write `review.md` in repo root with this structure:

1. Report context (mode, base branch or SHA, files reviewed, skipped files)
2. Findings summary counts by severity
3. Sections in this order:
   - `## Critical`
   - `## Warnings`
   - `## Suggestions`

Each finding must include:

- ID: `C1`, `C2`, `W1`, `W2`, `S1`, `S2`, ...
- File path
- Location (function/struct plus line number)
- Category
- Problem description
- Suggested fix

If a section has no findings, write `None.`

### 6. Present Results

After writing `review.md`, present:

1. Total findings by severity
2. Top 3 most important findings
3. Files with the most findings
4. Note whether Go-specific checks were applied or skipped
