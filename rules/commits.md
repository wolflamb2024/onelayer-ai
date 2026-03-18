# Commits

A Pull Request should contain multiple descriptive commits. Each commit should be self-contained and atomic, which is a fancy way of saying that each commit should contain a single change, and that change should be complete and not dependent on any other commit. This is because each (good) commit is a unit of work that can be reviewed, tested, and merged independently.

### First Line

The first line is a short summary prefixed by the primary affected package.

Write it to complete the sentence "This change modifies package X to _____." Don't start with a capital letter, don't make it a complete sentence, and actually summarize the change result. Use a verb that describes the functional outcome, not the mechanical file operation. For example, prefer `topology: document go package` over `topology: add package documentation`.

In the example: "This change modifies package math to improve Sin, Cos and Tan precision for very large arguments."

Follow the first line with a blank line.

### Main Content

The rest provides context and explains what the change does. Write complete sentences with correct punctuation, like Go comments. Don't use HTML, Markdown, or other markup languages.

Add relevant information like benchmark data if the change affects performance. Use [benchstat](https://godoc.org/golang.org/x/perf/cmd/benchstat) to format benchmark data.

Some rules of thumb:
1. The changeset of a commit should be reviewed in a few minutes.
2. If you find yourself writing a commit message that contains the words "and", "or", "also", then you should probably split the commit into two commits.
3. The scope of a "feature" commit should affect a single package.
4. If you find yourself struggling to attribute a commit to a single package, then you should probably split the commit into two commits.
5. When in doubt, split the commit into two commits.
6. Go module changes (go.mod / go.sum) must be split: one commit per `go mod init`, one commit per group of `go get` dependency. One group is all dependencies that has to be installed at commit X so commit X+1 can use it.

Here are some good reviewable commits:
1. Renaming a variable, and updating all references to that variable.
2. Refactoring the signature of a function, and updating all references to that function.
3. Moving a package to a new location, and updating all references to that package.
4. Fixing a typo in a package alongside a concise change to that package.
5. Ensure to read the Contribution Guidelines as it is crucial to craft high-quality, descriptive commit messages.


Here are some not-so-reviewable commits:
1. Fixing a typo in a package alongside a large refactor of another package.
2. Testing a type/function separately from its implementation.
3. Renaming a variable without updating all references to that variable.

### go.mod / go.sum Commits

Changes to `go.mod` and `go.sum` must be committed with fine granularity — one commit per operation:

- Module initialization: `go.mod: init {modulePath}` (e.g., `go.mod: init go.onelayer.dev/x/topology`)
- Each dependency group addition: `go.mod: get {dependencyPath1}, {dependencyPath2}, ...` (e.g., `go.mod: get go.onelayer.dev/x/component`)

One group of dependencies are all dependencies that have to be commited at commit X so it builds successfully on commit X+1 and go mod tidy is no action.


Now it is a matter of where to share that knowledge. Here some tips:
Commit Body: Provide detailed information about the timeline, history, and evolution of the codebase.
Package Documentation: Offer comprehensive details about the domain of interest related to the package.
Doc Comment: Describe how to use a specific symbol, whether exported or unexported, for users.
Inline Comments: Insert comments within the code to explain non-trivial or specific sections of the code.
