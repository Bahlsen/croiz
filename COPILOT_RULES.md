# Copilot Project Rules

These rules define how GitHub Copilot (the assistant) must operate in this repository. All automated changes and assistance MUST comply.

## Core Engineering Rules

- Test-Driven Development (TDD) is mandatory.
  - Write a failing test first that captures the intended behavior or bug.
  - Implement the minimal code to pass the new test without breaking existing tests.
  - Refactor only after tests are green.
  - New features or fixes MUST include appropriate tests.

- Respect SOLID and KISS at all times.
  - Extract helpers/services with single responsibility; keep widgets thin.
  - Favor simple, readable solutions over clever ones.

- Control bodies on new lines (style enforcement).
  - Always use explicit blocks for `if/else/for/while`.
  - Example: `if (cond) { return; }` not `if (cond) return;`.

- Pre-change workflow checks.
  - Frontend: write unit/widget tests under `frontend/test/`, run `flutter test`, and adhere to `analysis_options.yaml` (includes `always_put_control_body_on_new_line`).
  - Backend: write JUnit tests under `backend/src/test/`, run `./gradlew test`, and ensure format/lint are clean.

- Minimal, focused changes.
  - Edit only what is necessary for the current task.
  - Keep style consistent with the existing codebase.
  - Do not introduce unrelated refactors.

- Fail fast on invalid data.
  - Do not add silent fallbacks that mask errors.
  - Prefer explicit errors with actionable messages.

## Crossword Numbering Rules (Frontend)

- Numbers shown in the grid come from JSON `entries` (`board.entries`).
- Normalize entry starts to the first active cell in their direction:
  - Across: shift left until the left cell is black or column is 0.
  - Down: shift up until the above cell is black or row is 0.
- Validate entry paths:
  - Start cell must be non-black.
  - Path of `length` must remain in-bounds and avoid black cells.
- Do not require entries for every potential start cell; only validate the entries provided.
- Column-first display order is preferred where ordering is relevant.

## Workflow Expectations

- Use existing VS Code tasks for build/run where available.
- Run the most specific tests first (unit/widget), then broader suites if needed.
- Update or create documentation when behavior changes in a way users or developers must understand.

## Assistant Conduct

- Always state assumptions and next steps concisely.
- Prefer MCP tools and repo tasks over shell commands when applicable.
- Avoid adding licenses/headers unless explicitly requested.
- Avoid excessive verbosity; focus on actionable guidance.

## Engineering Principles

To keep the codebase healthy and maintainable, Copilot must adhere to the following principles:

- KISS (Keep It Simple, Stupid): Prefer straightforward solutions with minimal moving parts; avoid cleverness that reduces clarity. Choose simple data structures, small functions, and explicit flows over abstract or meta-programming unless clearly justified.
- SOLID:
  - Single Responsibility: Each module/class/file should have one reason to change. Avoid mixing UI, state, and pure logic.
  - Open/Closed: Extend behavior via composition or small new types; avoid modifying stable abstractions when adding features.
  - Liskov Substitution: Respect contracts; derived types must be usable wherever their base types are expected.
  - Interface Segregation: Prefer small, focused interfaces/APIs; don’t force dependents to implement unused methods.
  - Dependency Inversion: Depend on abstractions (interfaces) and inject collaborators; avoid hard dependencies on concrete implementations.

## Refactoring Guidelines

- Split monolithic files into focused modules and provide barrel exports to maintain backward compatibility.
- Extract impure logic (I/O, framework calls) from pure functions to enable testing.
- Keep public APIs stable; when necessary, add new adapters rather than breaking imports.
- Document rationale for structural changes in PR descriptions.