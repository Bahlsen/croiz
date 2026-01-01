# Changelog

All notable changes to the Croiz project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Language filter chips on the puzzle selection page
  - Users can now filter puzzles by language (FR, EN, UK)
  - Filters are displayed as interactive chips below the origin filter
- `PuzzleDescriptor.language` field to support multilingual puzzle metadata
- `puzzle_filter_provider.dart` with comprehensive filtering state management
- Unit tests for `inProgressPuzzlesProvider` with autodispose behavior

### Changed
- Migrated `HivePuzzleStorage` to use dependency injection via `PuzzleStorageInterface`
- Removed backward compatibility static methods from storage classes
- Improved puzzle metadata indexing for better performance

### Fixed
- Fixed puzzle persistence issues with proper Hive initialization
- Corrected test file naming conventions for consistency

### Removed
- Deprecated static `loadStatic`/`saveStatic` methods from `HivePuzzleStorage`
- Legacy backward compatibility code for puzzle storage migration

---

## [1.0.0] - 2024-XX-XX

### Added
- Initial release of Croiz crossword game
- Flutter mobile application with Riverpod state management
- Spring Boot REST API backend
- Offline puzzle play support
- In-app virtual keyboard (QWERTY/AZERTY layouts)
- Dark/Light theme support
- Multilingual UI (English, French, Ukrainian)
- Puzzle progress persistence with Hive
- Audio feedback system for game interactions
- Puzzle filtering by origin and year
- "Continue Playing" section for in-progress puzzles

### Technical
- GoRouter for declarative navigation
- Dio HTTP client with JWT authentication support
- Secure token storage with flutter_secure_storage
- PostgreSQL database with Flyway migrations
- Comprehensive test suite (unit, widget, integration)
- CI/CD with GitHub Actions

---

## Version Numbering

- **Major** (X.0.0): Breaking changes, major feature overhauls
- **Minor** (0.X.0): New features, backward-compatible
- **Patch** (0.0.X): Bug fixes, minor improvements

---

## Links

- [README](README.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Architecture Documentation](docs/architecture.md)
