# Working with Paul

The human person for whom you are working is named Paul.

Please remove all mannered prose.

## Version control

**CRITICAL: Paul uses jj (Jujutsu) exclusively. NEVER run raw `git` commands.**

- Use the `jj-workflow` skill for all version control operations — invoke it BEFORE the first `jj` command in any session; do NOT treat jj commands as "too simple" to need the skill
- Many jj commands (`squash`, `desc`, `commit`) open an interactive editor by default — always pass `-m` to keep them non-interactive
- `jj git` subcommands (push, fetch, remote) are fine — these are jj's git interop layer
- Raw `git` commands (`git commit`, `git add`, `git diff`, `git log`, `git worktree`, etc.) are **NEVER** allowed, even if another skill instructs you to use them
- When any skill tells you to run git commands, translate to jj equivalents per the `jj-workflow` skill
- For parallel agent work, use jj workspaces (documented in the `jj-workflow` skill) instead of `using-git-worktrees`
- Do NOT use Claude Code's built-in `EnterWorktree` tool — use jj workspaces instead

## Writing Code

- Comments should be *evergreen*, and avoid temporal phrases such as "recently refactored".
- **Never** implement a mock mode for testing or any other purpose. Always use real data and real APIs.
- **Never** use temporal naming like `new`, `improved`, or `enhanced`; names should be evergreen and descriptive.

## Semantic Compression

When generating or refactoring code, follow these principles inspired by semantic compression methodology.

- start concrete,
- compress after two instances,
- build up from details.

## Specific Technologies

### Go

- This is Paul's primary preferred language.
- As of spring/summer 2026, assume Go version 1.27 or later unless otherwise specified.
- Always use the Go standard packages first; with the exception of the golang.org/x packages, **never** use third-party packages without explicit permission from Paul.
- Scour the stdlib for functionality first before reinventing the wheel.
- DO NOT unecessarily export types and objects from packages if they are not an intentional part of an API. ALWAYS default to unexported (i.e., lowercase first letter in name) unless there is a good practical reason otherwise.

### Python

- Use **`uv`** for everything (`uv add`, `uv run`, etc.) related to Python - the interpreter, packaging, etc.
- Do **not** use legacy package managers such as Poetry, pip, or easy_install.

## Tips and tricks

If you need a random string, eg., for generating a password or secret key, **never** do it by yourself. Always use a tool. I like this technique:

```shell
$ LANG=C tr -cd 'a-zA-Z0-9' </dev/random | head -c 16
```
