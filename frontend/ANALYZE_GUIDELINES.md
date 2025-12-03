Flutter Analyze findings (automatically generated) and coding guidelines to address them

Summary of issues found during `flutter analyze` after adding end-of-game features:

- sort_constructors_first: Keep constructors before other methods/fields in classes.
- always_put_control_body_on_new_line: Put statements/expressions on their own lines for readability.
- cascade_invocations: Use cascade (..) when calling multiple methods on the same receiver.
- prefer_expression_function_bodies: Prefer concise '=>' for short functions that return an expression.
- prefer_const_constructors: Prefer `const` where possible for widgets and constructors.
- prefer_int_literals: Use integer literals instead of double when no fraction needed (e.g., `8` not `8.0`).
- unawaited_futures: Await asynchronous writes where appropriate or explicitly ignore with `unawaited(...)` from `package:pedantic` / `package:flutter/foundation.dart`.

Action items (KISS / SOLID / TDD):

1. When writing small helper classes (like `GameTimer`), place constructors first and then public API methods.
2. Write control statements on separate lines to improve diff clarity and reduce lint noise.
3. Use cascade (`..`) when performing multiple writes/operations on the same object to reduce duplication.
4. Prefer expression-bodied functions for tiny methods (e.g., simple getters/formatters).
5. Use `const` constructors and widgets when possible to improve performance.
6. Explicitly handle futures: either `await` them, or mark intentionally ignored futures with `unawaited(...)` and document why.

Follow-up checklist for this feature (TDD):
- Add unit tests for `GameTimer` persistence and `finalizeSync()` behavior.
- Add widget test for `EndGameOverlay` visibility when `foundWords` equals entries length.
- Re-run `flutter analyze` and fix items one-by-one; update this document with concrete code examples when a recurring lint appears.

If you want, I can apply the fixes for the low-priority analyzer hints now (convert to expression bodies, add const, use cascade, and add `unawaited` for storage writes). Tell me which of these you'd like me to auto-apply now.
