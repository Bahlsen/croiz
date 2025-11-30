# Copilot Project Rules

These rules define how GitHub Copilot (the assistant) must operate in this repository. All automated changes and assistance MUST comply.

## Core Engineering Rules

- Test-Driven Development (TDD) is mandatory.
  - Write a failing test first that captures the intended behavior or bug.
  - Implement the minimal code to pass the new test without breaking existing tests.
  - Refactor only after tests are green.
  - New features or fixes MUST include appropriate tests.

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