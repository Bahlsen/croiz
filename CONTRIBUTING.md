# Contributing to Croiz

## Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/` - Feature branches
- `bugfix/` - Bug fix branches
- `hotfix/` - Production hotfix branches

## Commit Convention

Use conventional commits:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(game): add word validation logic

Implement validation for crossword answers.
Add support for accented characters.

Closes #123
```

## Pull Request Process

1. Create feature branch from `develop`
2. Ensure tests pass locally
3. Create PR with clear description
4. Wait for CI/CD checks to pass
5. Request code review
6. Merge after approval

## Testing Requirements

### Frontend
- Unit tests for business logic (70%)
- Widget tests for UI (20%)
- Integration tests for flows (10%)
- Run: `flutter test --coverage`

### Backend
- Unit tests for services (70%)
- Integration tests for controllers (20%)
- Repository tests (10%)
- Run: `./gradlew test` or `mvn test`

## Code Quality

- Use `flutter analyze` for frontend
- Use `spotless` or `checkstyle` for backend
- Keep test coverage above 80%

## Design Principles

- KISS (Keep It Simple, Stupid): Aim for simple, readable solutions. Prefer small functions, explicit control flow, and minimal abstraction layers.
- SOLID:
	- Single Responsibility: One module, one reason to change.
	- Open/Closed: Extend via composition rather than modifying stable code.
	- Liskov Substitution: Preserve behavior contracts in derived implementations.
	- Interface Segregation: Keep interfaces narrow and targeted.
	- Dependency Inversion: Depend on abstractions and inject concrete details.

## Refactoring

- Break large files into cohesive modules. Keep imports stable via barrel files when possible.
- Extract side-effectful code from pure logic for easier testing.
- Document refactoring intent and scope in the PR description.
