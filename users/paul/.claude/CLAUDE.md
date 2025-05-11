# Working with Paul

## Interaction

- Any time you interact with me, you **MUST** address me as **"Paul"**.

## Code Writing

- Prefer *simple, clean, maintainable* solutions over clever or complex ones, even at the expense of conciseness or performance. Readability and maintainability are **primary concerns**.
- Make the **smallest reasonable changes** to achieve the desired outcome.
- Match the *style and formatting* of the surrounding code—even if it differs from external style guides. Consistency within a file trumps external standards.
- **Do not change whitespace** unrelated to the code you're modifying.
- **Never** make code changes unrelated to your current task. If you spot something else, document it in a new issue instead of fixing it immediately.
- **Never** remove code comments unless you can prove they are actively false. Comments are vital documentation.
- Every code file **MUST** start with a brief **two-line** comment explaining what the file does. Each line **MUST** begin with `ABOUTME: ` so it is easily greppable.
- Comments should be *evergreen*—avoid temporal phrases such as "recently refactored".
- **Never** implement a mock mode for testing or any other purpose. We always use real data and real APIs.
- **Never** discard existing implementations to rewrite from scratch without **explicit permission from Paul**.
- **Never** use temporal naming like `new`, `improved`, or `enhanced`; names should be evergreen and descriptive.

## Version Control

- Track all **non-trivial edits** in **git**.
- If the project is not yet in a git repo, **STOP** and ask permission before initializing one.
- If uncommitted changes or untracked files exist when you start, **STOP** and ask how to proceed—typically you should commit existing work first.
- If no clear branch exists for the current task, create a **WIP** branch.
- **Commit frequently** throughout development.

## Getting Help

- **Always** ask for clarification rather than making assumptions.
- If you are stuck or unsure, **STOP** and ask for help—especially where human input could be valuable.

## Testing

- Tests **MUST** comprehensively cover **all implemented functionality**.
- **Never** ignore system or test output; logs and messages often contain **critical** information.
- Test output **MUST** be pristine for tests to pass.
- If logs are expected to contain errors, ensure they are **captured and tested**.
- **No Exceptions Policy**: *Every* project must include **unit**, **integration**, **and** **end-to-end** tests. The only way to skip any test type is if Paul explicitly states: `I AUTHORIZE YOU TO SKIP WRITING TESTS THIS TIME`.

## Test-Driven Development (TDD)

We practice **strict TDD**:

1. Write a **failing test** that defines the desired functionality *before* writing implementation code.
2. Run the test to confirm it fails as expected.
3. Write **only** enough code to make the failing test pass.
4. Run the test suite to confirm success.
5. **Refactor** code while ensuring all tests remain green.
6. Repeat for each new feature or bug-fix.

## Specific Technologies

### Python

- Use **`uv`** for everything (`uv add`, `uv run`, etc.).
- Do **not** use legacy package managers such as Poetry, pip, or easy_install.
- Ensure a **`pyproject.toml`** exists at the repository root.  
  - If it does not exist, create one by running `uv init`.

### Go

- Assume Go version 1.23 or later unless otherwise specified.
- Always use the standard packages first; **never** use third-party packages without explicit permission from Paul.
- Ensure a **`go.mod`** file exists at the repository root.  
  - If it does not exist, create one by running `go mod init <module-name>`.

## Compliance Check

Before submitting any work, verify that you have followed **all** guidelines above. If you find yourself considering an exception to **any** rule, **STOP** and obtain explicit permission from **Paul** first.
