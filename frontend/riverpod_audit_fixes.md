# Riverpod Audit Fix Proposals

Generated from `frontend/riverpod_audit_report.txt`.

For each flagged file below I list the finding and a concise proposed code edit. Many matches are valid Riverpod usage (widgets/providers). Only a few require changes; others get optional suggestions to improve maintainability.

---

- `lib/main.dart` (lines with `ref.watch`):
  - Finding: `ref.watch(appIsDarkProvider)` and `ref.watch(localeProvider)` in `ConsumerState` `build` method.
  - Proposal: No code change required; `ref.watch` is correct in `build`. Optional: wrap locale/theme reads in `select` if you want to further narrow rebuilds (not required).

- `lib/services/providers.dart`:
  - Finding: Contains provider definitions and a comments block referencing `ProviderContainer`.
  - Proposal: Already annotated with project conventions. No further code edits required.

- `lib/widgets/in_game_text_input.dart` (use of `.notifier`):
  - Finding: Calls `ref.read(gameBoardProvider.notifier).clearIncorrectLetters()` in widget state.
  - Proposal: No change — using `.read(...).notifier` in widget callbacks is correct.

- `lib/features/home/home_screen.dart` (`context.` usage):
  - Finding: `context` used in widget. Fine if inside widget lifecycle.
  - Proposal: No change. If `context` is used inside async callbacks after await, ensure `mounted` checks (already common pattern).

- `lib/features/puzzles/puzzles_list_page.dart` (`ref.watch` usage):
  - Finding: `ref.watch` used inside widget build — acceptable.
  - Proposal: No change. Optional: use `.select` on heavy providers.

- `lib/features/splash/splash_screen.dart` (`ref.watch`):
  - Finding: Widget-level `ref.watch` usage.
  - Proposal: No change.

- `lib/features/game/controllers/crossword_input_controller.dart`:
  - Finding: Factory `fromContainer(ProviderContainer container)` exists.
  - Proposal: Leave factory for tests, but add a small comment clarifying intended usage (tests only). Recommend avoiding storing ProviderContainer in long-lived app objects; prefer `fromRef(WidgetRef)` in production code. I'll add a brief comment above the factory.

- `lib/features/game/controllers/*` (lots of `.notifier` reads):
  - Finding: Uses `.notifier` in controller code to call provider notifiers.
  - Proposal: These controllers already accept a `read` function and call `_read(... .notifier)`. No change required. If any controller uses `ref.watch` directly, refactor to accept a `Reader`/`read` function (not observed in main controller).

- `lib/features/game/providers/*.dart` and `lib/features/game/widgets/*.dart` (many `ref.watch` calls):
  - Finding: `ref.watch` calls are in widgets or provider implementations.
  - Proposal: No change. For widgets that rebuild often (grid/cell), keep `select` usage as present. Consider creating derived small providers for complex selections to reduce rebuilds only if profiling shows hot paths.

- `lib/features/game/widgets/end_game_overlay.dart` and other widget files with `context.` or `.notifier`:
  - Finding: Widget-level usage of `context` and notifier writes.
  - Proposal: No change needed. Ensure `ref.listen` is used for side-effects (navigation/toasts) rather than watching values and calling side-effects inside `build`.

- `lib/features/puzzles/widgets/puzzle_list_widgets.dart` (`context.` / `.notifier)`):
  - Finding: Widget-level uses.
  - Proposal: No code change.

- Files flagged for `.watch` occurrences in providers: `cell_providers.dart`, `game_board_provider.dart`, `game_providers.dart`, `game_state_providers.dart`, `puzzle_loader_provider.dart`
  - Finding: Providers calling `ref.watch` inside provider (allowed) or inside provider build methods.
  - Proposal: No change. Use `ref.watch` inside provider `build` functions is allowed. If you have long-running services created from a provider and they store `ref.watch`, prefer using `ref.read` or pass dependency values explicitly.

---

Summary of actual code edits I propose applying now:
1. Add a clarifying comment near `CrosswordInputController.fromContainer` noting it's for tests only and should not be used in production long-lived objects.

I avoided making automatic changes in widget/provider files since their Riverpod usage is appropriate; bulk edits there risk unnecessary churn. If you want, I can instead refactor any specific file you pick to move `ref.watch` out of a non-widget location or to narrow rebuilds.

If you confirm, I'll apply the small comment edit to `lib/features/game/controllers/crossword_input_controller.dart` and mark the audit as addressed. Alternatively, tell me a subset of flagged files you want me to refactor automatically.
