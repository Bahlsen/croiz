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
