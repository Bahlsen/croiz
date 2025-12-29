# Riverpod Checklist (croiz)

Short checklist derived from https://riverpod.dev/docs/root/do_dont

- Root: App must be wrapped in `ProviderScope` (see `main.dart`).
- Widgets: use `ref.watch` or `ref.listen` inside `build` / lifecycle with care.
- Callbacks/async: use `ref.read` (or `ref.read(...).notifier`) to mutate state.
- Long-lived non-widget objects (controllers/services): do NOT use `ref.watch`; accept a `Reader`/`read` function or use `ProviderContainer` only in tests.
- Performance: prefer `ref.watch(provider.select((s) => ...))` to minimize rebuilds.
- Side-effects: use `ref.listen` for one-off reactions (navigation, toasts, etc.).
- Tests: use `ProviderContainer` and `UncontrolledProviderScope` for isolated testing.
- Families/autoDispose: prefer `family` for parameterised providers and `autoDispose` for ephemeral state.

If you want, I can add a CI lint step that runs `frontend/tools/riverpod_audit.py` and fails on heuristic issues.
