# Working Guide

## Issue

Creating an issue may seem simple, but a well-defined issue helps current and future developers understand the purpose of the work.

### Types

Issue types reflect the kind of effort needed. Different types require different formats and structures.

- **Incident** - A reported issue that describe an unexpected behavior requiring investigation.
- **Bug** - A system malfunction that result in unexpected behavior.
- **Enhancement** - A request, idea, or new functionality.
- **Operational** - Work related to environment configurations, upgrades, and deployment support.
- **Initiative** - A large, overarching work item that groups related efforts.
- **Prototype** - A preview, proof-of-concept, or temporary enhancement.

Each issue type has a distinct purpose. For example, an issue marked as "Initiative" tells readers this is a large effort that may have sub-issues linked to it. An "Incident" issue tells readers an investigation will be conducted, often linking to a Bug that describes the root cause or the underlying problem and tracks its resolution.

### Title Naming

#### Enhancements, Prototypes and Initiatives

Issue titles should use the **present progressive** to show new capabilities being added to the OneLayer codebase. This makes it clear the issue represents ongoing work. A good title starts with a verb that clearly states the expected outcome.

Good examples:

1. Optimizing image compression for faster load times
2. Documenting API endpoints for external developers
3. Shifting MAC vendor lookup capability to asset-views
4. Verifying manufacturer in the CSV against list

These verbs clearly show what action the issue aims to achieve.

When choosing a verb, avoid vague ones like "Enhancing, Implementing, Exposing, etc." While these are verbs, they don't convey real action and only mislead readers. If you "enhance" then use a more specific verb to describe how the outcome is better. Like optimized, simpler, well documented, less error prone, etc. There may be edge cases where these verbs fit, but use them sparingly.

#### Body

Don't assume readers are familiar with all the history, topics, or knowledge needed to understand the issue's purpose.

Provide enough context. The issue doesn't need to document everything, but should give readers necessary background and point to other resources to fill gaps.

Issues must contain goals. Use the phrase "By the time this issue is complete, ..." to highlight the goal.

Most issues need requirements that define the scope. This helps both writers and readers understand what must be done to mark the issue as complete.

Most issues have halting conditions - checkpoints that guide the assignee toward success.

A good issue body includes these sections:

- **Motivation** - Establishes the "why" behind the issue, providing context and rationale.
- **Scope of Work** - Defines the "what" - specific tasks to accomplish.
- **Goal** - Focuses on the desired outcome or end-state.
- **Requirements** - Documents specific needs or conditions for successful completion.
- **Halting Conditions** - Outlines checkpoints that must be met for the issue to be considered complete.

The above are not blank fields to fill in, like a table. They are questions the body of the document should answer, in whatever form fits. We prefer paragraph-based text with fewer headings.

#### Incident

Incidents are raw reports of unexpected behavior. Sometimes developers diagnose bugs directly, but often we log the misbehavior for later triage.

Incident titles should begin with the misbehaving **subject**, followed by a verb in present progressive describing the misbehavior:

1. Network twin is failing to process messages
2. Dashboard loading times increasing
3. User authentication failing intermittently
4. Mobile app crashing on startup
5. Search function returning inaccurate results
6. Database connections dropping unexpectedly

The incident body should provide information for successful investigation. Good questions to answer:

- What happened?
- Where did this happen?
- What did you expect?
- How can we reproduce the incident?
- Does it affect customers?

#### Bugs

Bug titles must begin with the misbehaving subject, followed by a verb in present simple describing the misbehavior:

1. Network twin freezes on empty IP field
2. Dashboard performs duplicate requests
3. Mobile app crashes when closed forcefully

The bug body should describe the actual bug, similar to Enhancement format but focused on fixing the present bug. Describe the bug, not the solution.

If you have a **possible** fix to mention, add it as a comment on the issue.

### Issue Closed Reasons

When closing an issue on GitHub, explain **why**.

Update the appropriate reason. Most importantly, when work is dropped or redirected, select "**Close as not planned**" with a comment providing context.

The *reason* field is important for management views. Please respect it.

Options:

- **Close as completed** - Done, closed, fixed, resolved
- **Close as not planned** - Won't fix, can't repro, stale
- **Close as duplicate** - Duplicate of another issue

---

## Pull Request

A pull request is a developer's request to contribute to the codebase. As a request, it should be presented thoughtfully and carefully.

Good pull requests result from nice, well-maintained code and happy future developers.

### Branch Naming

Every pull request begins with a branch that encapsulates the work done.

**Descriptive and Concise Names:**
Branch names should clearly indicate purpose while staying relatively short.

When one branch encapsulates work from one issue, relate the branch name to the issue name. Example: If an enhancement issue is called *Exposing changes in multiple devices' properties*, a good branch name is `feature/expose-device-properties`.

**Prefixes for Categorization:**
Use prefixes to help readers:

- `feature/`: For new features
- `bugfix/`: For fixing bugs
- `docs/`: For creating or updating documentation
- `experiment/`: For experimenting with new capabilities
- `refactor/`: For code refactoring

**Kebab-Case for Readability:**
Use hyphens to separate words (kebab-case). Example: `feature/expose-user-profile` is preferred over `feature/exposeUserProfile` or `feature_expose_user_profile`.

**Lowercase Characters:**
Use only lowercase letters for consistency and to avoid case-sensitivity issues across operating systems.

### Title

The most important part of a Pull Request is the title. It should be short, descriptive, written in present tense, and use the imperative mood. This title generates the commit message when merged, and commit messages are clearer with commands/verbs. Remember that Pull Request titles appear in Release Notes.

Examples:

- Instead of "**Fixed** bug with the login page", write "**Fix** bug with the login page"
- Instead of "**Adding** new dashboard feature", write "**Add** new dashboard feature"
- Instead of "**Data isolation for** the network-twin", write "**Support** data isolation **between** network-twins"

The title should be a **valid, grammatically correct sentence** in English. It's **not** a book title **nor** a branch name.

Take time to think about the Pull Request's value; arriving at a quality title takes effort.

### Description

The description should contain a **brief summary** of changes and **reasons** for them. Include **relevant links** to Issues, other Pull Requests, or external resources. Write in active voice.

A good description flows naturally, helping readers understand the issue. When linking relevant sources, well-constructed sentences and paragraphs provide clarity.

GitHub uses this description as the commit message body when merging. Feel free to use Markdown, but remember `git` doesn't support it and will render as plain text.

Take time to think about the value you've added; arriving at a quality description takes time and effort.

### Proofs

Every developer should include proof of work with their pull request. This allows reviewers to see your code in action and verify it matches the required outcome.

Proof helps stakeholders review outcomes and helps reviewers understand changes. Include screenshots, videos, or captured logs.

Issues are the best place for proofs since they describe the problem or feature. Include proof as a comment in the issue before closing it. Don't edit the issue description to add proof - proof shows the work done, not the problem itself. Sometimes proof can be commented in the Pull Request, but this isn't standard practice.

Include links to comments containing proofs. Add links at the end of the Pull Request description prefixed with `Proof:`:

```
... Pull Request description ...

Proof: https://github.com/OneLayerHQ/atmosphere/issues/5#issuecomment-1566271703
Proof: https://github.com/OneLayerHQ/atmosphere/pull/13#pullrequestreview-1469493791
```

These render as clickable links and propagate to the commit message when merged.

### Commits

A Pull Request should contain multiple descriptive commits. Each commit should be **self-contained** and **atomic** - containing a single, complete change not dependent on other commits. Each good commit is a **unit of work** that can be reviewed, tested, and merged independently.

Rules of thumb:

- A commit's changeset should be reviewable in minutes
- If your commit message contains "and", "or", "also", split into two commits
- A "feature" commit should affect a single package
- If you struggle to attribute a commit to one package, split it
- When in doubt, split the commit

Not-so-reviewable commits:

- Fixing a typo alongside a large refactor in another package
- Testing a type/function separately from its implementation
- Renaming a variable without updating all references

#### Good Commit Messages

Commit messages in OneLayer follow specific conventions.

Example of a good commit message:

```
math: improve Sin, Cos and Tan precision for very large arguments

The existing implementation has poor numerical properties for
large arguments, so use the McGillicutty algorithm to improve
accuracy above 1e10.

The algorithm is described at https://wikipedia.org/wiki/McGillicutty_Algorithm
```

**First Line**

The first line is a short summary prefixed by the primary affected package.

Write it to complete the sentence "This change modifies package X to _____." Don't start with a capital letter, don't make it a complete sentence, and actually summarize the change result.

In the example: "This change modifies package math to improve Sin, Cos and Tan precision for very large arguments."

Follow the first line with a blank line.

**Main Content**

The rest provides context and explains what the change does. Write complete sentences with correct punctuation, like Go comments. Don't use HTML, Markdown, or other markup languages.

Add relevant information like benchmark data if the change affects performance.

**Motivation**

Keeping commits **atomic** makes it easier to identify bug sources and revert changes. Using `git bisect` to find malicious commits requires recompiling at each point - impossible if commits aren't atomic.

Commit messages answer questions not relevant when reading code, only when reading the commit.

Where to share knowledge:

1. **Commit Body:** Timeline, history, and codebase evolution
2. **Package Documentation:** Domain details related to the package
3. **Doc Comment:** How to use specific symbols
4. **Inline Comments:** Explain non-trivial code sections

Take time to rewrite history and split commits; it shows you're a good, caring developer.

### Commit Order

Each commit should be **self-contained** and **atomic**. The sequence tells the story of your changes. Good commit order doesn't reflect developer work but shows feature evolution layer by layer, helping readers understand codebase evolution.

Tips for commit order:

**Declaring Symbols Only When Using Them** - Declare symbols when using them to help readers understand their purpose and usage. Delaying usage creates cognitive load.

**Commit Length** - Keep commits reasonably small to reduce cognitive load. Since each commit is atomic and builds on the next, small, focused commits are easier to understand.

**Go Module Commits** - When working with Go modules (initializing, getting dependencies, updating versions), separate these actions into their own commits.

**Refactoring** - Refactoring packages/files should be in separate commits. This shows readers that the codebase structure changed and provides a place to document reasons.
