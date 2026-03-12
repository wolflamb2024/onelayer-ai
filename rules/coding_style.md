# Go Coding Style Rules (Compact)

## 1) Priorities (in order)
1. Clarity
2. Simplicity
3. Concision
4. Maintainability
5. Consistency

If tradeoffs conflict, optimize for the highest item above.

## 2) Core readability rules
- Prefer code that is easy to read over easy to write.
- Names should reveal intent; comments should explain **why**, not restate **what**.
- Use comments to call out non-obvious behavior, edge cases, language/API nuances, and performance-motivated complexity.
- Avoid cleverness and unnecessary abstraction.
- Use the least mechanism:
  1. language primitives
  2. standard library
  3. internal/shared library
  4. new dependency only with justification
- New dependencies must be justified (why this one, alternatives, maintenance/docs quality).

## 3) Formatting and naming
- `gofmt` output is mandatory.
- Use `MixedCaps` / `mixedCaps`; avoid snake_case in Go identifiers.
- No hard line-length limit. Refactor before wrapping awkwardly.
- Avoid repetitive names:
  - Don't repeat package names in functions.
  - Don't repeat receiver names in methods.
  - Don't use `Get` prefix for getters.
- Function naming:
  - noun-like when returning a value (`JobName`)
  - verb-like when performing action (`WriteTo`)
- Keep local naming consistent within file/package.
- Avoid vague package names like `util`, `helper`, `common`.

## 4) Package and file structure
- Package boundaries should reflect domain cohesion and caller ergonomics.
- Keep files focused; avoid giant files and excessive tiny-file fragmentation.
- `doc.go` is optional for package docs.

## 5) Imports
- Mandatory grouping order:
  1. standard library
  2. external/general imports
  3. internal OneLayer imports
- Optional extra groups are allowed (e.g., proto, side-effect) if consistently maintained.
- Proto import aliases should be descriptive; prefer `...pb` / `...grpc` suffixes.

## 6) Error handling
- Errors are values: handle deliberately, don't ignore blindly.
- Prefer structured/typed/sentinel errors over string matching.
- Use `errors.Is` / `errors.As` for classification.
- Add context only when useful and non-duplicative.
- Use `%w` only when callers should unwrap; treat wrapping as API surface.
- Prefer `%w` at end: `"context: %w"`.
- At system boundaries (RPC/IPC/storage), map to canonical error space/codes.
- Avoid double logging: if returning an error, usually let caller log.
- Log messages should be actionable and avoid PII.
- Initialization/config errors should bubble to `main`, which logs actionable message and exits with code `2`.

## 7) Panics and process termination
- Prefer returning errors in libraries.
- Use panic only for:
  - clear API misuse/invariant violation
  - internal panic/recover pattern that never escapes package boundary
  - unreachable code markers
- Do not rely on panic recovery for normal control flow.

## 8) Documentation
- Document non-obvious behavior, constraints, cleanup requirements, and important error semantics.
- Don't over-document obvious params.
- Context cancellation behavior is implicit unless special.
- Concurrency guarantees should be documented when non-obvious or contract-critical.
- Prefer runnable examples for usage.
- Use proper godoc formatting (paragraph spacing, headings, indented blocks).

## 9) Variables and initialization
- Prefer `:=` for non-zero initialization.
- Use zero-value declarations when value is intentionally empty-and-ready.
- Use composite literals when initial members are known.
- Prefer pointer forms where required (e.g., protobuf messages).
- Preallocate slices/maps only when justified by known size/perf evidence.
- Specify channel direction (`<-chan`, `chan<-`) when possible.

## 10) API argument design
- Keep function signatures short and clear.
- For many options, prefer:
  - option struct (simpler/default for many required options)
  - variadic functional options (when many optional/infrequent options)
- `context.Context` is never inside option structs.
- In variadic options, options are applied in order; last wins for conflicts.

## 11) CLI guidance
- For rich subcommand CLIs, default to `cobra` unless another library better fits.
- In cobra handlers, use `cmd.Context()`.
- Separate reusable library code from CLI wiring where practical.

## 12) Testing
- Keep pass/fail decisions in `Test` functions.
- Prefer table-driven tests over repetitive assertions.
- Avoid assertion-helper patterns; helpers should mostly do setup/cleanup.
- Test helpers that fail setup should use `t.Helper()` + `t.Fatal*` with clear context.
- Do not call `t.Fatal*` from goroutines (use `t.Error*` + return).
- Use field names in large table test structs.
- Scope setup to tests that need it; avoid global test init side effects.
- Use `TestMain` only when all tests need shared setup + teardown.
- `sync.Once` setup is okay for expensive shared setup without teardown.
- Prefer real transports in integration tests.

## 13) String building
- Use `+` for simple concatenation.
- Use `fmt.Sprintf` for formatted strings.
- Use `fmt.Fprintf` when writing directly to `io.Writer`.
- Use `strings.Builder` for incremental construction in loops.
- Use raw string literals (backticks) for constant multiline strings.

## 14) Global state
- Prefer explicit dependency injection over package-level mutable state.
- Avoid global registries/singletons for behavior control.
- Global state is only acceptable in narrow cases (effectively constant, stateless observable behavior, no cross-test interference).
- If a default global instance is exposed for convenience:
  - also expose explicit instance API
  - keep global API a thin proxy
  - document/enforce invariants and provide reset for tests

## 15) Practical defaults for reviewers/authors
- Ask: Is this clearer, simpler, and easier to change in 6 months?
- Flag unfamiliar patterns unless justified by measurable need (performance, shared API ergonomics, etc.).
- Prefer consistency within package unless it conflicts with higher-priority style rules.
