# Documentation Map

This document provides an overview of all documentation files in the Croiz project.

## Quick Navigation

| Document | Purpose | Location |
|----------|---------|----------|
| [README](README.md) | Project overview & quick start | Root |
| [Architecture](docs/architecture.md) | System design & patterns | docs/ |
| [API Documentation](docs/api.md) | REST API endpoints | docs/ |
| [Setup Guide](docs/setup.md) | Development environment | docs/ |
| [Testing Strategy](docs/testing.md) | Test guidelines | docs/ |
| [Contributing](CONTRIBUTING.md) | Contribution guidelines | Root |
| [Changelog](CHANGELOG.md) | Version history | Root |

---

## Root Documentation

### Primary Documents

| File | Description |
|------|-------------|
| `README.md` | Main project overview, quick start, tech stack |
| `CONTRIBUTING.md` | Guidelines for contributors, commit conventions |
| `CHANGELOG.md` | Version history following Keep a Changelog format |
| `LICENSE` | Project license terms |
| `QUICK_REFERENCE.md` | Quick command reference |
| `INITIALIZATION.md` | Initial project setup guide |
| `COPILOT_RULES.md` | AI assistant guidelines |
| `GEMINI.md` | Gemini agent configuration |

### Configuration

| File | Description |
|------|-------------|
| `.github/copilot-instructions.md` | Detailed AI coding guidelines |
| `.github/agents/Flutter.agent.md` | Flutter specialist agent persona |

---

## `/docs/` Directory

### Architecture & Design

| File | Description |
|------|-------------|
| `architecture.md` | Complete system architecture overview |
| `puzzle-system.md` | Crossword puzzle mechanics explanation |
| `puzzle-schema.md` | Puzzle JSON data structure |
| `puzzle-creation-guide.md` | How to create new puzzles |
| `in-app-keyboard.md` | Virtual keyboard implementation |

### Setup & Configuration

| File | Description |
|------|-------------|
| `setup.md` | Full development environment setup |
| `firebase-setup.md` | Firebase configuration guide |
| `firebase-credentials.md` | Credentials management |
| `ios-firebase-setup.md` | iOS-specific Firebase setup |
| `ios-setup-checklist.md` | iOS development checklist |

### Development

| File | Description |
|------|-------------|
| `api.md` | REST API endpoint documentation |
| `testing.md` | Testing strategy and guidelines |
| `refactor_plan.md` | Planned refactoring notes |
| `puzzle-selection-refonte-plan.md` | Puzzle selection redesign plan |

---

## Frontend Documentation (`/frontend/`)

### Main Documentation

| File | Description |
|------|-------------|
| `README.md` | Frontend project overview |

### Layer Documentation (`lib/`)

| Directory | README | Description |
|-----------|--------|-------------|
| `lib/core/` | ✅ `README.md` | Constants, theme, utilities |
| `lib/data/` | ✅ `README.md` | Models, repositories, data sources |
| `lib/domain/` | ✅ `README.md` | Entities, use cases, business logic |
| `lib/features/` | ✅ `README.md` | Feature module overview |
| `lib/services/` | ✅ `README.md` | Providers and services |

### Feature Documentation

| Feature | README | Description |
|---------|--------|-------------|
| `features/game/` | ✅ `README.md` | Core crossword gameplay |
| `features/puzzles/` | ✅ `README.md` | Puzzle selection and browsing |
| `features/home/` | ❌ | Home screen |
| `features/splash/` | ❌ | Splash/loading screen |

---

## Backend Documentation (`/backend/`)

### Main Documentation

| File | Description |
|------|-------------|
| `README.md` | Backend project overview |
| `src/main/resources/application.yaml` | Configuration with inline docs |

### API Documentation

- See [API Documentation](docs/api.md) for full endpoint reference
- View Swagger UI at `/swagger-ui.html` when running locally (if configured)

---

## Code Documentation

### Dart/Flutter

All public APIs should have dartdoc comments:

```dart
/// Loads puzzle metadata from the asset bundle.
///
/// Returns a [PuzzleDescriptor] containing basic puzzle information
/// such as title, origin, and difficulty.
///
/// Throws [StateError] if the puzzle file cannot be parsed.
///
/// Example:
/// ```dart
/// final descriptor = await loadPuzzleMetadata('puzzle_001');
/// print(descriptor.title);
/// ```
Future<PuzzleDescriptor> loadPuzzleMetadata(String id) async { ... }
```

### Key Documented Files

| File | Purpose |
|------|---------|
| `lib/services/providers.dart` | Central Riverpod providers |
| `lib/features/puzzles/puzzles_provider.dart` | Puzzle data providers |
| `lib/features/game/providers/crossword_state_provider.dart` | Game state management |

---

## Generating Documentation

### Dart Documentation

```bash
cd frontend
dart doc .
# Open doc/api/index.html
```

### Backend (if using Javadoc)

```bash
cd backend
./gradlew javadoc
# Open build/docs/javadoc/index.html
```

---

## Documentation Standards

### General Rules

1. **Keep docs up-to-date** - Update docs with code changes
2. **Use clear language** - Write for the intended audience
3. **Include examples** - Show code examples where helpful
4. **Link related docs** - Cross-reference related documentation

### README Structure

Each feature/module README should include:
1. Overview/Purpose
2. Directory Structure
3. Key Components
4. Usage Examples
5. Related Documentation

### Code Comments

- Use dartdoc (`///`) for public APIs
- Explain *why*, not just *what*
- Keep comments current with code changes

---

## Contributing to Documentation

When making changes:

1. Update relevant READMEs for affected modules
2. Update CHANGELOG.md for user-facing changes
3. Update API docs for endpoint changes
4. Run `flutter analyze` to catch doc issues

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.
