# Working with Paul

## Interaction

- Any time you interact with me, you **MUST** address me as **"Paul"**.

## Code Writing

- Favor **semantic compression** as your approach to writing or changing code. See the section below for details.
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

## Semantic Compression

When generating or refactoring code, follow these principles inspired by semantic compression methodology to minimize long-term human effort and maximize code maintainability.

### Implementation Guidelines

- **Start concrete, compress later**: Always begin by writing exactly what needs to happen in each specific case without regard to abstraction or "correctness" buzzwords. Get it working first, then look for compression opportunities.
- **Apply the two-instance rule**: Never create reusable code until you have at least two actual instances of duplication. Make your code usable before trying to make it reusable.
- **Avoid premature abstraction**: Writing "reusable" code upfront without real examples leads to cumbersome interfaces that require later rework. Wait until you have concrete use cases to inform the abstraction.
- **Use real examples to guide design**: When creating reusable code, always base the design on at least two different real examples of what the code needs to do. This ensures the abstraction fits actual usage patterns.
- **Practice semantic compression**: Like a dictionary compressor, continuously look for opportunities to reduce duplicated or similar code while preserving meaning and functionality.
- **Choose optimal reuse strategies**: When encountering new places where existing code could be reused, decide whether to: use as-is, modify the existing code, or introduce new layers (above or below existing code).
- **Build from details up**: Start with working details and compress upward to arrive at architecture, rather than designing abstract architectures first and trying to fill in details later.
- **Prioritize readability through compression**: Well-compressed code is naturally more readable because it contains minimal redundancy and the semantics mirror the real "language" of the problem domain.
- **Ensure maintainability**: All code paths doing identical operations should go through the same reusable components, while unique code remains close to its usage without unnecessary complexity.
- **Design for extensibility**: Structure compressed code so that adding similar functionality is straightforward by recomposing existing, well-factored components.

### Expected Outcomes

Following these guidelines produces code that is:
- Easy to read (minimal redundancy, domain-appropriate semantics)
- Easy to maintain (shared operations use common paths, unique code stays simple)  
- Easy to extend (new similar functionality builds on existing reusable components)
- Robust (based on real examples rather than speculative requirements)

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
