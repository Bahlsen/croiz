# Copilot Instructions for croiz

Purpose: Provide concise guidance for AI coding agents and human contributors working in the croiz monorepo. Use this as an operational checklist and quick reference.

Table of contents
- Big Picture
- Architecture Patterns
- Key Workflows
- Conventions & Patterns
- Integration Points
- Testing Strategy
- CI/CD Notes
- When Implementing New Code
- Engineering Principles
- Quick Commands
- PR Checklist
- Maintainers & Contact
- Branching & Releases
- Minimum Environment Versions
- Secrets & Credentials
- How to get help

Maintainers & contact
- **Repo owner**: `Bahlsen` (GitHub organization owner)
- **Primary support**: open an Issue in this repository and request reviewers; use CODEOWNERS if present for reviewer suggestions.

PR Checklist (recommended)
- **Run unit tests**: Frontend `cd frontend; flutter test` and Backend `cd backend; .\gradlew test`.
- **Run linters/formatters**: Frontend `flutter analyze` / `flutter format .`; Backend `./gradlew spotlessCheck` / `./gradlew spotlessApply`.
- **Run migrations & DB checks**: If DB schema changes, add a Flyway migration under `backend/src/main/resources/db/migration/`.
- **Update docs**: Add or modify `docs/` and `shared/` DTOs when API contracts change.
- **Add tests**: Include unit tests for logic and minimal integration tests where applicable.
- **Security check**: Don't commit secrets; add config to `.env.example` and use GitHub Secrets for CI.

Branching & releases (recommended)
- Use feature branches: `feature/<short-description>` or `fix/<issue-number>`.
- Target `main` for PRs; keep `main` protected in your repo settings.
- Prefer squash merges for a clean history unless the team prefers merge commits.

Minimum environment versions (recommended)
- **Flutter**: recommended stable channel (list version in project README if strict requirement exists).
- **Dart**: use the SDK bundled with the recommended Flutter version.
- **Java**: `17+` (project uses Java 17 in CI examples).
- **Gradle**: use the Gradle wrapper included in `backend/`.

Secrets & credentials
- Do not commit API keys, Firebase credentials, or private keys. Use `gitignore` and store samples in `.env.example` or `application-test.yaml` for tests.
- Use GitHub Actions secrets or your org's secret store for CI values.

How to get help
- Open an Issue in this repository describing the problem with steps to reproduce, logs, and environment details.
- For urgent or interactive help, use the project's preferred chat (Slack/Mattermost) if available — otherwise mention maintainers in the issue.

These guidelines help AI coding agents work productively in this repository. Focus on the actual structure and workflows used here.

Solo developer mode — strict rules
- You're the single maintainer: move fast, but maintain discipline. When in doubt, follow these rules — no negotiation.
- Always run tests and format locally before pushing. If you push broken code to `main`, fix it immediately and push a follow-up commit with the message `fix: restore main — <short reason>`.
- Use `conventional-commits` style for commit messages (e.g. `feat: add crossword generator`, `fix(auth): handle token refresh`).

Enforcement checklist (no excuses)
- **Local checks (mandatory)**: run these before commit:
  - `cd frontend; flutter analyze && flutter format . && flutter test`
  - `cd backend; .\gradlew spotlessCheck && .\gradlew test`
- **Pre-commit hooks**: install `pre-commit` and use hooks to run formatters and tests; example `.pre-commit-config.yaml` should include a formatter step (Flutter/Dart) and a simple test runner or linter. If you don't want global `pre-commit`, add a local script `scripts/precommit.ps1` and call it from your editor.
- **CI expectations**: CI must pass on every merge to `main`. Set a minimal coverage gate (recommended 70% overall or per-module for new features).

Quick git workflow (solo, tactical)
- Fast patch to `main` (when safe):
  - `git checkout main; git pull --rebase origin main; git commit -am "fix: <short description>"; git push origin main`
- Feature branch (preferred for non-trivial work):
  - `git checkout -b feature/short-description`
  - make changes, run local checks
  - `git add -A && git commit -m "feat: short description"`
  - `git push origin feature/short-description` (create PR if you want review later)

Fast recovery
- If `main` is broken after a push, revert the offending commit or push a fix immediately. Use `git revert <bad-commit>` when appropriate; prefer small, targeted fixes with clear messages.

Optional but useful
- Add a `scripts/` folder with `precommit.ps1`, `ci-local.ps1` to run the exact CI commands locally. Keep scripts small and deterministic.

Tone and style
- Be direct in commit messages and PR descriptions. Name-by-purpose: files, functions, and commits should describe exactly what changed and why.

## Big Picture
- **Monorepo** with two primary apps:
  - `frontend/` Flutter mobile app (Riverpod, GoRouter, Dio, Sqflite, secure storage).
  - `backend/` Spring Boot API (Gradle, PostgreSQL, Flyway, JWT).
- **Shared assets** and utilities:
  - `shared/` models/constants (referenced by docs; keep Flutter DTOs and backend DTOs consistent).
  - `tools/` Python scripts for crossword generation (`generate_puzzle.py`).
- See `README.md` and `docs/architecture.md` for overviews; align code with these.

## Architecture Patterns
- **Frontend layering** (see `frontend/README.md` and `lib/`):
  - Presentation → Riverpod providers → Usecases/Services → Repositories → Datasources (API/local).
  - Organize features under `lib/features/<feature>/` and domain in `lib/domain/`.
  - Example providers live in `lib/services/providers.dart` (Dio, auth, game, stats).
- **Backend layering** (see `backend/README.md` and `src/main/java/com/croiz/`):
  - Controller → Service → Repository → Entity (JPA) with DTOs, `security/`, `config/`, and Flyway migrations in `src/main/resources/db/migration/`.
  - Keep controller contracts aligned with `docs/api.md`.

## Key Workflows
- **Frontend dev**:
  - Install deps: `cd frontend; flutter pub get`.
  - Run app: `flutter run` (device/emulator required).
  - Codegen (when needed): `flutter pub run build_runner build` (or `watch`).
  - Tests: `flutter test` (coverage: `flutter test --coverage`; compute extra: `dart run tools/compute_coverage.dart`).
  - Integration tests require a device: `flutter test integration_test/app_test.dart -d <device-id>`.
- **Backend dev**:
  - Run: `cd backend; .\\gradlew bootRun`.
  - Tests: `.\\gradlew test` (coverage: `.\\gradlew jacocoTestReport`).
  - Formatting: `.\\gradlew spotlessCheck` / `spotlessApply`.
  - Migrations: add `V{N}__description.sql` under `src/main/resources/db/migration/`; Flyway runs at startup.
- **Android build tasks in VS Code** (Tasks panel):
  - Build APK release: `Android: Build APK (release)` → runs `flutter build apk --release` with Android/Java env.
  - Quick install/debug/hot reload: `Android: Run (debug, hot reload)` or Wi‑Fi variants via `frontend/tools/install_apk.ps1`.
  - System env helper: `Android: Set ANDROID_HOME (system)`.

## Conventions & Patterns
- **Frontend**:
  - Riverpod providers centralised in `lib/services/providers.dart` and per‑feature modules.
  - Use GoRouter for navigation (`lib/routes/`), keep routes declarative.
  - Data models in `lib/data/models/`; repositories in `lib/data/repositories/`; datasources in `lib/data/datasources/`.
  - Prefer `AsyncValue<T>` for async state; expose `StateNotifier` for complex flows.
  - Store tokens in secure storage; persistent data in Sqflite; simple prefs in `shared_preferences`.
- **Backend**:
  - Controllers return DTOs; avoid exposing entities directly.
  - Security via JWT (config in `src/main/resources/application.yaml`); use profiles: `default`, `test`, `prod`.
  - Tests favour MockMvc + H2; configuration in `application-test.yaml`.
  - Keep logs configured via `logging.level.com.croiz` in `application.yaml`.

## Integration Points
- **HTTP**: Flutter uses Dio; define base client/provider and APIs against `docs/api.md`.
- **Auth**: JWT issued by backend; Flutter stores tokens in secure storage; include Authorization headers via Dio interceptors provider.
- **Data**: Puzzles generated by `tools/generate_puzzle.py`; sample data under `frontend/assets/data/`.

## Testing Strategy
- **Frontend**: majority unit tests under `frontend/test/unit/`, widget tests under `frontend/test/widget/`, integration tests under `frontend/test/integration_test/` (device required).
- **Backend**: unit + integration tests via Gradle; coverage with JaCoCo; prefer service‑level unit tests and controller integration with MockMvc.

## CI/CD Notes
- GitHub Actions workflows in `.github/workflows/` run lint, tests, coverage, builds, and optional Firebase distribution. Flutter integration tests in CI must target a booted emulator; locally, pass `-d`.

## Examples to Follow
- Flutter provider examples in `lib/services/providers.dart` (dioProvider, authProvider, gameProvider, statsProvider stubs).
- Android tooling scripts in `frontend/tools/` for install/run/hot reload.
- Backend migration example `V1__Initial_schema.sql` and `application.yaml` for logging.

## When Implementing New Code
- Mirror existing layer boundaries (no cross‑layer shortcuts).
- Place new features under the established `features/` and `domain/` structure.
- Keep API contracts in sync with `docs/api.md`; update DTOs and tests together.
- Prefer repository abstractions; avoid direct HTTP calls from widgets or services.
 - When creating UI widgets that may need to change vertical space depending on parent layout, prefer exposing a caller-controlled parameter (e.g. `heightFactor` in range `0.0-1.0`) instead of hardcoding multipliers inside the widget. Example: `CrosswordControlsBar` exposes `heightFactor` (default `0.4`) so callers can request more space (the app uses `heightFactor: 0.8` where appropriate). Update all call sites and tests when changing this contract.

## Engineering Principles
- **KISS**: Favor straightforward solutions over clever ones. Keep widgets/providers small, single-purpose; avoid deep inheritance and unnecessary abstractions.
- **SOLID**: 
  - Single Responsibility: each `Service`, `Repository`, and `Controller` owns one concern.
  - Single Responsibility Principle (SRP): a module or class should have one,
    and only one, reason to change — i.e., a single responsibility. Practically,
    keep business logic (services) separate from UI (widgets) and from state
    orchestration (providers/notifiers). When behavior grows, prefer extracting
    a small service with focused unit tests rather than adding complexity to
    an existing class.
  - Open/Closed: extend behavior via new implementations (e.g., new datasource) rather than modifying existing ones.
  - Liskov: keep interchangeable implementations consistent (e.g., repository interfaces used by services).
  - Interface Segregation: define narrow interfaces for domain/repository contracts.
  - Dependency Inversion: depend on abstractions; wire concrete implementations via providers/config.
- **TDD**: Write tests first for business logic. 
  - Frontend: unit tests in `frontend/test/unit/`, widget tests in `frontend/test/widget/`; use Riverpod testing utilities and mock `Dio`.
  - Backend: service tests with JUnit/Mockito; controller integration with MockMvc and H2 using `application-test.yaml`.
  - Aim for fast tests; push integration tests to CI/emulator when needed.

## Quick Commands (PowerShell)
- `cd frontend; flutter pub get; flutter run`
- `cd frontend; flutter test --coverage; dart run tools/compute_coverage.dart`
 - After finishing frontend changes: run `flutter analyze` and apply automated fixes with `flutter fix --apply`.
- `cd backend; .\\gradlew test jacocoTestReport`
- `cd tools; pip install -r requirements.txt; python generate_puzzle.py`

---
Questions or unclear areas? Tell us what’s missing (e.g., provider locations, API routes needing confirmation, or build runner usage), and we’ll refine this file.
