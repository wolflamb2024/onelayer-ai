# OneLayer Go Style Guide

This document is **normative and canonical**.

For the compact quick-reference version, see [coding_style.md](coding_style.md).

---

## Style Principles

There are a few overarching principles that summarize how to think about writing readable Go code. The following are attributes of readable code, in order of importance:

1. **Clarity**: The code's purpose and rationale is clear to the reader.
2. **Simplicity**: The code accomplishes its goal in the simplest way possible.
3. **Concision**: The code has a high signal-to-noise ratio.
4. **Maintainability**: The code is written such that it can be easily maintained.
5. **Consistency**: The code is consistent with the broader OneLayer codebase.

### Clarity

The core goal of readability is to produce code that is clear to the reader. Clarity is primarily achieved with effective naming, helpful commentary, and efficient code organization. Clarity is to be viewed through the lens of the reader, not the author of the code. It is more important that code be easy to read than easy to write.

Clarity in code has two distinct facets:

**What is the code actually doing?**

Go is designed such that it should be relatively straightforward to see what the code is doing. In cases of uncertainty or where a reader may require prior knowledge, it is worth investing time to make the code's purpose clearer. For example:

- Use more descriptive variable names
- Add additional commentary
- Break up the code with whitespace and comments
- Refactor the code into separate functions/methods to make it more modular

**Why is the code doing what it does?**

The code's rationale is often sufficiently communicated by the names of variables, functions, methods, or packages. Where it is not, it is important to add commentary. The "Why?" is especially important when the code contains nuances that a reader may not be familiar with, such as:

- A nuance in the language, e.g., a closure will be capturing a loop variable, but the closure is many lines away
- A nuance of the business logic, e.g., an access control check that needs to distinguish between the actual user and someone impersonating a user
- An API that might require care to use correctly

It is also important to be aware that some attempts to provide clarity (such as adding extra commentary) can actually obscure the code's purpose by adding clutter, restating what the code already says, contradicting the code, or adding maintenance burden.

The OneLayer codebase is meant to be largely uniform and consistent. Code that stands out (e.g., by using an unfamiliar pattern) must be doing so for a good reason, for example, performance.

### Simplicity

Your Go code should be simple for those using, reading, and maintaining it. Within the OneLayer Go codebase, simple code:

- Is easy to read from top to bottom.
- Does not assume that you already know what it is doing.
- Does not assume that you can memorize all of the preceding code.
- Does not have unnecessary levels of abstraction.
- Does not have names that call attention to something mundane.
- Makes the propagation of values and decisions clear to the reader.
- Has comments that explain why, not what, the code is doing to avoid future deviation.
- Has documentation that stands on its own.
- Has useful errors and useful test failures.
- May often be mutually exclusive with "clever" code.

When code needs complexity, the complexity should be added deliberately. This is typically necessary if additional performance is required or where there are multiple disparate customers of a particular library or service. Complexity may be justified, but it should come with accompanying documentation.

If code turns out to be very complex when its purpose should be simple, this is often a signal to revisit the implementation to see if there is a simpler way to accomplish the same thing.

### Least Mechanism

Where there are several ways to express the same idea, prefer the one that uses the most standard tools:

1. Aim to use a core language construct (channel, slice, map, loop, struct) when sufficient.
2. If there isn't one, look for a tool within the standard library (HTTP client, template engine).
3. Finally, consider whether there is a core library in the OneLayer codebase that is sufficient before introducing a new dependency or creating your own.

When introducing a new dependency, a developer must explain why this dependency is required. Explain why this specific dependency was chosen and why alternatives were not considered. Check:

- Is it well-known?
- Is it well-maintained?
- Is it well-documented?

In cases where the dependency is not well-maintained or documented, we prefer to copy the needed code into our codebase and maintain it ourselves.

### Concision

Concise Go code has a high signal-to-noise ratio. It is easy to discern the relevant details, and the naming and structure guide the reader through these details.

Things that get in the way of surfacing the most salient details:

- Repetitive code
- Extraneous syntax
- Opaque names
- Unnecessary abstraction
- Whitespace

Understanding and using common code constructions and idioms are important for maintaining a high signal-to-noise ratio. For example:

```go
// Good:
if err := doSomething(); err != nil {
    // ...
}
```

If code looks very similar to this but is subtly different, a reader may not notice. In such cases, "boost" the signal:

```go
// Good:
if err := doSomething(); err == nil { // if NO error
    // ...
}
```

### Maintainability

Maintainable code:

- Is easy for a future programmer to modify correctly.
- Has APIs that are structured so that they can grow gracefully.
- Is clear about the assumptions that it makes and chooses abstractions that map to the structure of the problem, not to the structure of the code.
- Avoids unnecessary coupling and doesn't include features that are not used.
- Has a comprehensive test suite to ensure promised behaviors are maintained.

Maintainable code also avoids hiding important details in places that are easy to overlook:

```go
// Bad:
// The use of = instead of := can change this line completely.
if user, err = db.UserByID(userID); err != nil {
    // ...
}

// Good:
u, err := db.UserByID(userID)
if err != nil {
    return fmt.Errorf("invalid origin user: %s", err)
}
user = u
```

```go
// Bad:
// The ! in the middle of this line is very easy to miss.
leap := (year%4 == 0) && (!(year%100 == 0) || (year%400 == 0))

// Good:
// Gregorian leap years aren't just year%4 == 0.
// See https://en.wikipedia.org/wiki/Leap_year#Algorithm.
var (
    leap4   = year%4 == 0
    leap100 = year%100 == 0
    leap400 = year%400 == 0
)
leap := leap4 && (!leap100 || leap400)
```

Predictable names are another feature of maintainable code. A user of a package or a maintainer of a piece of code should be able to predict the name of a variable, method, or function in a given context.

Maintainable code minimizes its dependencies (both implicit and explicit). Avoiding dependencies on internal or undocumented behavior makes code less likely to impose a maintenance burden when those behaviors change in the future.

### Consistency

Consistent code is code that looks, feels, and behaves like similar code throughout the broader codebase. Consistency concerns do not override any of the principles above, but if a tie must be broken, it is often beneficial to break it in favor of consistency.

Consistency within a package is often the most immediately important level. It can be very jarring if the same problem is approached in multiple ways throughout a package.

---

## Core Guidelines

### Formatting

All Go source files must conform to the format outputted by the `gofmt` tool. Generated code should generally also be formatted.

**MixedCaps**: Go source code uses `MixedCaps` or `mixedCaps` rather than underscores. This applies even when it breaks conventions in other languages. For example, a constant is `MaxLength` (not `MAX_LENGTH`) if exported and `maxLength` (not `max_length`) if unexported.

**Line length**: There is no fixed line length. If a line feels too long, prefer refactoring instead of splitting it. Do not split a line before an indentation change or to make a long string fit into multiple shorter lines.

### Naming

Names should:

- Not feel repetitive when they are used
- Take the context into consideration
- Not repeat concepts that are already clear

### Local Consistency

Where the style guide has nothing to say about a particular point of style, authors are free to choose the style that they prefer, unless the code in close proximity has taken a consistent stance.

Examples of **valid** local style considerations:

- Use of `%s` or `%v` for formatted printing of errors
- Usage of buffered channels in lieu of mutexes

Examples of **invalid** local style considerations:

- Line length restrictions for code
- Use of assertion-based testing libraries

---

## Naming Decisions

### Function and Method Names

#### Avoid Repetition

- Do not repeat the name of the package:

```go
// Bad:
package yamlconfig
func ParseYAMLConfig(input string) (*Config, error)

// Good:
package yamlconfig
func Parse(input string) (*Config, error)
```

- Do not repeat the name of the method receiver:

```go
// Bad:
func (c *Config) WriteConfigTo(w io.Writer) (int64, error)

// Good:
func (c *Config) WriteTo(w io.Writer) (int64, error)
```

- Do not repeat the names of variables passed as parameters:

```go
// Bad:
func OverrideFirstWithSecond(dest, source *Config) error

// Good:
func Override(dest, source *Config) error
```

- Do not repeat the names and types of the return values:

```go
// Bad:
func TransformToJSON(input *Config) *jsonconfig.Config

// Good:
func Transform(input *Config) *jsonconfig.Config
```

When it is necessary to disambiguate functions of a similar name, it is acceptable to include extra information:

```go
// Good:
func (c *Config) WriteTextTo(w io.Writer) (int64, error)
func (c *Config) WriteBinaryTo(w io.Writer) (int64, error)
```

#### Naming Conventions

- Functions that return something are given **noun-like** names:

```go
func (c *Config) JobName(key string) (value string, ok bool)
```

- Do not use the `Get` prefix for getters:

```go
// Bad:
func (c *Config) GetJobName(key string) (value string, ok bool)
```

- Functions that do something are given **verb-like** names:

```go
func (c *Config) WriteDetail(w io.Writer) (int64, error)
```

- Functions that differ only by the types involved include the type at the end:

```go
func ParseInt(input string) (int, error)
func ParseInt64(input string) (int64, error)
```

If there is a clear "primary" version, the type can be omitted:

```go
func (c *Config) Marshal() ([]byte, error)
func (c *Config) MarshalText() (string, error)
```

### Shadowing and Stomping

**Stomping** (reusing `:=` to reassign an existing variable) is OK when the original value is no longer needed:

```go
// Good:
func (s *Server) innerHandler(ctx context.Context, req *pb.MyRequest) *pb.MyResponse {
    ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
    defer cancel()
    // Code here no longer has access to the original context.
}
```

**Shadowing** (`:=` in a new scope creates a new variable) can introduce bugs:

```go
// Bad:
func (s *Server) innerHandler(ctx context.Context, req *pb.MyRequest) *pb.MyResponse {
    if *shortenDeadlines {
        ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
        defer cancel()
    }
    // BUG: "ctx" here is the original context, not the shortened one.
}

// Good:
func (s *Server) innerHandler(ctx context.Context, req *pb.MyRequest) *pb.MyResponse {
    if *shortenDeadlines {
        var cancel func()
        ctx, cancel = context.WithTimeout(ctx, 3*time.Second) // = not :=
        defer cancel()
    }
}
```

Do not use variables with the same name as standard packages other than in very small scopes:

```go
// Bad:
func LongFunction() {
    url := "https://example.com/"
    // Oops, now we can't use net/url in code below.
}
```

### Util Packages

Naming a package just `util`, `helper`, `common` or similar is usually a poor choice. Instead, consider what the callsite will look like:

```go
// Good:
db := spannertest.NewDatabaseFromFile(...)
_, err := f.Seek(0, io.SeekStart)
b := elliptic.Marshal(curve, x, y)

// Bad:
db := test.NewDatabaseFromFile(...)
_, err := f.Seek(0, common.SeekStart)
b := helper.Marshal(curve, x, y)
```

### Test Double Packages

When creating a package that contains test doubles for another, append the word `test` to the original package name:

```go
package creditcardtest
```

**Simple case** (one double for one type):

```go
// Stub stubs creditcard.Service and provides no behavior of its own.
type Stub struct{}
func (Stub) Charge(*creditcard.Card, money.Money) error { return nil }
```

**Multiple behaviors**:

```go
type AlwaysCharges struct{}
func (AlwaysCharges) Charge(*creditcard.Card, money.Money) error { return nil }

type AlwaysDeclines struct{}
func (AlwaysDeclines) Charge(*creditcard.Card, money.Money) error {
    return creditcard.ErrDeclined
}
```

**Multiple types** (more explicit naming):

```go
type StubService struct{}
func (StubService) Charge(*creditcard.Card, money.Money) error { return nil }

type StubStoredValue struct{}
func (StubStoredValue) Credit(*creditcard.Card, money.Money) error { return nil }
```

**Local variables** for test doubles should be prefixed to distinguish from production types:

```go
// Good:
var spyCC creditcardtest.Spy
proc := &Processor{CC: spyCC}
```

---

## Package Size

Users see godoc for the package in one page. If client code is likely to need two values of different type to interact with each other, it may be convenient to have them in the same package.

Code within a package can access unexported identifiers. If you have a few related types whose implementation is tightly coupled, placing them in the same package lets you achieve this without polluting the public API.

As a general guideline: files should be focused enough that a maintainer can tell which file contains something, and small enough that it will be easy to find once there.

Reference examples:

- **Small**: `encoding/csv` (one cohesive idea, split into reader.go and writer.go)
- **Moderate**: `flag` (one domain, all in flag.go)
- **Large**: `net/http` (several closely related domains across client.go, server.go, cookie.go)

---

## Imports

### Protocol Buffer Messages and Stubs

Proto library imports use renamed imports with convention:

- `pb` suffix for `go_proto_library` rules
- `grpc` suffix for `go_grpc_library` rules

```go
import (
    foopb "path/to/package/foo_service_go_proto"
    foogrpc "path/to/package/foo_service_go_grpc"
)
```

Prefer whole words. Short names are good, but avoid ambiguity.

### Import Ordering

Mandatory groups, in order:

1. Standard library imports (e.g., `"fmt"`)
2. External/general imports
3. Internal OneLayer imports
4. (optional) Protobuf imports
5. (optional) Side-effect imports (e.g., `_ "path/to/package"`)

---

## Error Handling

### Error Structure

If callers need to interrogate the error, give the error value structure so this can be done programmatically rather than with string matching.

**Sentinel errors**:

```go
var (
    ErrDuplicate = errors.New("duplicate")
    ErrMarsupial = errors.New("marsupials are not supported")
)

func process(animal Animal) error {
    switch {
    case seen[animal]:
        return ErrDuplicate
    case marsupial(animal):
        return ErrMarsupial
    }
    seen[animal] = true
    return nil
}
```

Compare with `==` for sentinel values. Use `errors.Is` when errors may be wrapped:

```go
// Good:
switch err := process(an); {
case errors.Is(err, ErrDuplicate):
    return fmt.Errorf("feed %q: %v", an, err)
case errors.Is(err, ErrMarsupial):
    // Try to recover with a friend instead.
}
```

**Never** distinguish errors based on their string form:

```go
// Bad:
if regexp.MatchString(`duplicate`, err.Error()) { ... }
```

### Adding Information to Errors

Annotate errors with extra information, but avoid duplicating what the callee already provides:

```go
// Good:
if err := os.Open("settings.txt"); err != nil {
    return fmt.Errorf("launch codes unavailable: %v", err)
}
// Output: launch codes unavailable: open settings.txt: no such file or directory

// Bad:
if err := os.Open("settings.txt"); err != nil {
    return fmt.Errorf("could not open settings.txt: %w", err)
}
// Output: could not open settings.txt: open settings.txt: no such file or directory
```

### Error Stack and Call Chain Considerations

Each function in the call chain should provide only the context relevant to itself. Do not repeat information that lower layers already include:

```go
// Good:
func loadConfig(filename string) error {
    data, err := ioutil.ReadFile(filename)
    if err != nil {
        return fmt.Errorf("read file: %w", err)
    }
    return nil
}
// Error: "Failed to load configuration: read file: open settings.yaml: no such file or directory"

// Bad:
func loadConfig(filename string) error {
    data, err := ioutil.ReadFile(filename)
    if err != nil {
        return fmt.Errorf("failed to load config from %s: %w", filename, err)
    }
    return nil
}
// Error: "Error loading configuration from settings.yaml:
//         failed to load config from settings.yaml:
//         open settings.yaml: no such file or directory"
```

### Placement of %w in Errors

Prefer to place `%w` at the end of an error string so that error text mirrors error chain structure:

```go
// Good:
err2 := fmt.Errorf("err2: %w", err1)
err3 := fmt.Errorf("err3: %w", err2)
fmt.Println(err3) // err3: err2: err1

// Bad:
err2 := fmt.Errorf("%w: err2", err1)
err3 := fmt.Errorf("%w: err3", err2)
fmt.Println(err3) // err1: err2: err3 (oldest-to-newest, confusing)
```

Use `%w` only when you also document and test the underlying errors you expose. If you do not expect callers to call `errors.Unwrap`, `errors.Is`, etc., don't bother with `%w`.

### Logging Errors

- Log messages should clearly express what went wrong and help the maintainer diagnose the problem.
- Avoid duplication: if you return an error, it's usually better not to log it yourself but let the caller handle it.
- Be careful with PII in logs.
- Use `slog.Error` sparingly. `ERROR` level logging causes a flush and is more expensive. Error-level messages should be actionable rather than "more serious" than a warning.
- Prefer OneLayer's global monitoring system over just logging.

### Program Initialization

Program initialization errors (bad flags, configuration) should be propagated upward to `main`, which should log the error and exit with `os.Exit(2)`. In these cases, `log.Fatal` should not generally be used. A human-generated, actionable message is more useful than a stack trace.

### When to Panic

The standard library panics on API misuse. This is acceptable for:

- Clear API misuse or invariant violation
- Internal panic/recover pattern that **never escapes package boundaries**:

```go
// Good:
func Parse(in string) (_ *Node, err error) {
    defer func() {
        if p := recover(); p != nil {
            sErr, ok := p.(*syntaxError)
            if !ok {
                panic(p) // Propagate: outside our domain.
            }
            err = fmt.Errorf("syntax error: %v", sErr.msg)
        }
    }()
    // ...
}
```

- Unreachable code markers:

```go
func answer(i int) string {
    switch i {
    case 42:
        return "yup"
    default:
        log.Fatalf("Sorry, %d is not the answer.", i)
        panic("unreachable")
    }
}
```

Do not rely on panic recovery for normal control flow. Resist the temptation to recover panics to avoid crashes.

---

## Documentation

### Parameters and Configuration

Not every parameter must be enumerated in the documentation. Document error-prone or non-obvious fields by saying **why** they are interesting:

```go
// Bad:
// format is the format, and data is the interpolation data.
func Sprintf(format string, data ...any) string

// Good:
// The provided data is used to interpolate the format string. If the data does
// not match the expected format verbs, the function will inline warnings about
// formatting errors into the output string.
func Sprintf(format string, data ...any) string
```

### Contexts

It is implied that cancellation of a context argument interrupts the function. This does not need to be restated. Document context behavior only when it is different or non-obvious:

```go
// Good:
// Run executes the worker's run loop.
func (Worker) Run(ctx context.Context) error

// Good (non-obvious behavior):
// Run executes the worker's run loop.
//
// If the context is cancelled, Run returns a nil error.
func (Worker) Run(ctx context.Context) error
```

### Concurrency

Read-only operations are assumed safe for concurrent use. Mutating operations are assumed NOT safe. Document only when this assumption does not hold:

```go
// Good (read-only that is NOT safe):
// Lookup returns the data associated with the key from the cache.
//
// This operation is not safe for concurrent use.
func (*Cache) Lookup(key string) (data []byte, ok bool)
```

### Cleanup

Document explicit cleanup requirements:

```go
// Good:
// NewTicker returns a new Ticker containing a channel that will send the
// current time on the channel after each tick.
//
// Call Stop to release the Ticker's associated resources when done.
func NewTicker(d Duration) *Ticker
```

### Errors

Document significant error sentinel values or error types:

```go
// Good:
// Read reads up to len(b) bytes from the File and stores them in b.
//
// At end of file, Read returns 0, io.EOF.
func (*File) Read(b []byte) (n int, err error)

// Chdir changes the current working directory to the named directory.
//
// If there is an error, it will be of type *PathError.
func Chdir(dir string) error
```

### Godoc Formatting

- A blank line separates paragraphs.
- Indenting lines by two additional spaces formats them verbatim.
- A single line that begins with a capital letter, contains no punctuation except parentheses and commas, and is followed by another paragraph, is formatted as a **header**.

Preview documentation with `pkgsite` before and during code review.

### Signal Boosting

When code looks like a common pattern but is subtly different, add a comment to draw attention:

```go
// Good:
if err := doSomething(); err == nil { // if NO error
    // ...
}
```

---

## Variable Declarations

### Initialization

Prefer `:=` over `var` when initializing with a non-zero value:

```go
// Good:
i := 42

// Bad:
var i = 42
```

### Zero Values

Use zero-value declarations when the value is intentionally empty and ready for later use:

```go
// Good:
var (
    coords Point
    magic  [4]byte
    primes []int
)

// Bad:
var (
    coords = Point{X: 0, Y: 0}
    magic  = [4]byte{0, 0, 0, 0}
    primes = []int(nil)
)
```

For pointer types, `new` or `&T{}` are both fine:

```go
// Good:
msg := new(pb.Bar) // or "&pb.Bar{}"
```

Protobufs should be declared as pointer types because `*pb.Something` satisfies `proto.Message` while `pb.Something` does not.

### Composite Literals

Use composite literals when you know initial elements:

```go
// Good:
var (
    coords   = Point{X: x, Y: y}
    magic    = [4]byte{'I', 'W', 'A', 'D'}
    primes   = []int{2, 3, 5, 7, 11}
    captains = map[string]string{"Kirk": "James Tiberius", "Picard": "Jean-Luc"}
)
```

### Size Hints

Preallocate only when justified by known size or performance evidence:

```go
// Good:
var (
    buf  = make([]byte, 131072)
    q    = make([]Node, 0, 16)
    seen = make(map[string]bool, shardSize)
)
```

Most code does not need size hints. When in doubt, use zero initialization.

### Channel Direction

Specify channel direction where possible:

```go
// Good:
func sum(values <-chan int) int { ... }
```

---

## Function Argument Lists

### Option Structure

When a function has many parameters, use an option struct:

```go
// Good:
type ReplicationOptions struct {
    Config              *replicator.Config
    PrimaryRegions      []string
    ReadonlyRegions     []string
    ReplicateExisting   bool
    OverwritePolicies   bool
    ReplicationInterval time.Duration
    CopyWorkers         int
    HealthWatcher       health.Watcher
}

func EnableReplication(ctx context.Context, opts ReplicationOptions) { ... }
```

`context.Context` is never inside option structs.

Prefer this when: all callers specify some options, many callers provide many options, or options are shared between multiple functions.

### Variadic Options

Use variadic functional options when many options are optional/infrequent:

```go
type ReplicationOption func(*replicationOptions)

func ReadonlyCells(cells ...string) ReplicationOption {
    return func(opts *replicationOptions) {
        opts.readonlyCells = append(opts.readonlyCells, cells...)
    }
}

func EnableReplication(ctx context.Context, config *placer.Config, primaryCells []string, opts ...ReplicationOption) {
    var options replicationOptions
    for _, opt := range DefaultReplicationOptions {
        opt(&options)
    }
    for _, opt := range opts {
        opt(&options)
    }
}
```

Options should accept parameters rather than using presence to signal their value (prefer `rpc.FailFast(enable bool)` over `rpc.EnableFailFast()`). Options are applied in order; last wins for conflicts.

The parameter to the option function is generally unexported to restrict options to the package itself.

---

## Complex Command-Line Interfaces

For rich subcommand CLIs, **cobra** is recommended. Use `cmd.Context()` in cobra command functions rather than creating your own root context. Separate reusable library code from CLI wiring where practical.

---

## Tests

### Leave Testing to the Test Function

**Test helpers** do setup/cleanup. **Assertion helpers** check correctness and fail the test. Assertion helpers are not considered idiomatic in Go.

The ideal place to fail a test is within the `Test` function itself. If many separate test cases require the same validation logic:

1. Inline the logic in the `Test` function (simple cases).
2. Unify into a table-driven test while keeping logic inlined in the loop.
3. Arrange the validation function to return a value (typically `error`) rather than taking `testing.T`.

The `cmp` package is a good example: it compares values without needing to know the test context.

### Acceptance Testing

For testing that user-implemented types conform to an interface contract, create a test helper package that validates implementations as a blackbox:

```go
// ExercisePlayer tests a Player implementation in a single turn.
//
// It returns a nil error if the player makes a correct move.
func ExercisePlayer(b *chess.Board, p chess.Player) error
```

End users use it like:

```go
func TestAcceptance(t *testing.T) {
    player := deepblue.New()
    err := chesstest.ExerciseGame(t, chesstest.SimpleGame, player)
    if err != nil {
        t.Errorf("Deep Blue player failed acceptance test: %v", err)
    }
}
```

### Use Real Transports

When testing component integrations, prefer using the real underlying transport to connect to the test version of the backend, rather than hand-implementing the client.

### t.Error vs. t.Fatal

Use `t.Fatal` when setup fails and the rest of the test cannot proceed. In table-driven tests:

- Without `t.Run` subtests: use `t.Error` followed by `continue`
- With `t.Run` subtests: use `t.Fatal` (ends current subtest only)

### Error Handling in Test Helpers

When test helpers fail, prefer calling `Fatal` functions since a setup precondition failed:

```go
// Good:
func mustLoadDataset(t *testing.T) []byte {
    t.Helper()
    data, err := os.ReadFile("path/to/your/project/testdata/dataset")
    if err != nil {
        t.Fatalf("Could not load dataset: %v", err)
    }
    return data
}
```

The failure message should include a description of what happened. Use `t.Cleanup` for teardown.

### Don't Call t.Fatal from Separate Goroutines

It is incorrect to call `t.FailNow`, `t.Fatal`, etc. from any goroutine but the one running the Test function. Use `t.Error` + `return` instead:

```go
// Good:
go func() {
    defer wg.Done()
    if err := engine.Vroom(); err != nil {
        t.Errorf("No vroom left on engine: %v", err)  // NOT t.Fatalf
        return
    }
}()
```

### Use Field Names in Struct Literals

In table-driven tests, prefer field names when initializing test case struct literals:

```go
// Good:
tests := []struct {
    slice     []string
    separator string
    skipEmpty bool
    want      string
}{
    {
        slice:     []string{"a", "b", ""},
        separator: ",",
        want:      "a,b,",
    },
    {
        slice:     []string{"a", "b", ""},
        separator: ",",
        skipEmpty: true,
        want:      "a,b",
    },
}
```

### Keep Setup Code Scoped to Specific Tests

Call setup functions explicitly in test functions that need them. Don't use `init()` or package-level variables for test data:

```go
// Good:
func TestParseData(t *testing.T) {
    data := mustLoadDataset(t)
    // ...
}

// Bad:
var dataset []byte
func init() {
    dataset = mustLoadDataset()
}
```

### When to Use TestMain

Use `TestMain` only when **all tests in the package** require common setup and the setup requires teardown:

```go
func TestMain(m *testing.M) {
    code, err := runMain(context.Background(), m)
    if err != nil {
        log.Fatal(err)
    }
    os.Exit(code)
}
```

### Amortizing Common Test Setup

Use `sync.Once` when setup is expensive, only applies to some tests, and does not require teardown:

```go
var dataset struct {
    once sync.Once
    data []byte
    err  error
}

func mustLoadDataset(t *testing.T) []byte {
    t.Helper()
    dataset.once.Do(func() {
        dataset.data, dataset.err = os.ReadFile("testdata/dataset")
    })
    if err := dataset.err; err != nil {
        t.Fatalf("Could not load dataset: %v", err)
    }
    return dataset.data
}
```

---

## String Concatenation

- Use `+` for simple concatenation
- Use `fmt.Sprintf` when formatting
- Use `fmt.Fprintf` when writing directly to `io.Writer`
- Use `strings.Builder` for incremental construction in loops
- Use backticks for constant multiline strings

```go
// Good:
str := fmt.Sprintf("%s [%s:%d]-> %s", src, qos, mtu, dst)

// Bad:
bad := src.String() + " [" + qos.String() + ":" + strconv.Itoa(mtu) + "]-> " + dst.String()
```

---

## Global State

Libraries should not force clients to use APIs that rely on global state.

### Major Forms of Package State APIs

Problematic forms include:

- **Top-level variables** (exported or unexported)
- **Service locator pattern** with a global locator
- **Registries for callbacks**
- **Thick-client singletons** for backends, storage, etc.

### Litmus Tests

Global state APIs are **unsafe** when:

- Multiple functions interact via global state when executed in the same program, despite being otherwise independent.
- Independent test cases interact with each other through global state.
- Users are tempted to swap or replace global state for testing purposes.
- Users have to consider special ordering requirements (func init, flags, etc.).

Global state is **safe** when any of the following is true:

- The global state is logically constant.
- The package's observable behavior is stateless (e.g., a private cache).
- The global state does not bleed into things external to the program.
- There is no expectation of predictable behavior (e.g., `math/rand`).

### Providing a Default Instance

If you need to maximize convenience, it is acceptable to provide a simplified API that uses package-level state, provided:

1. The package also offers the ability to create isolated instances.
2. The public APIs using global state are a thin proxy to the instance API (like `http.Handle` delegates to `http.DefaultServeMux.Handle`).
3. The package-level API documents and enforces its invariants and provides an API to reset global state for tests.
