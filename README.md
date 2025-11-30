# Croiz - French Crossword Game

[![CI](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml/badge.svg)](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml)

A modern mobile crossword game built with Flutter and Spring Boot, featuring real-time gameplay, user authentication, and comprehensive scoring systems.

## Project Structure

```
croiz/
├── frontend/          # Flutter mobile application (Riverpod state management)
├── backend/           # Spring Boot REST API
├── shared/            # Shared models and constants
├── .github/workflows/ # CI/CD pipelines
└── docs/              # Project documentation
```

## Tech Stack

### Frontend
- **Framework**: Flutter 3.38+
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Sqflite + flutter_secure_storage
- **Testing**: flutter_test, mockito, golden_toolkit

### Backend
- **Framework**: Spring Boot 4.0+
- **Database**: PostgreSQL
- **Security**: Spring Security + JWT
- **Build Tool**: Gradle/Maven
- **Testing**: JUnit 5, MockMvc, H2 (in-memory)

## Quick Start

### Prerequisites
- Flutter 3.38+ with Dart 3.10+
- Java 21 LTS
- PostgreSQL 14+
- Git

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

### Backend Setup
```bash
cd backend
./gradlew bootRun
# or
mvn spring-boot:run
```

## Documentation

- [Architecture](docs/architecture.md)
- [API Documentation](docs/api.md)
- [Setup Guide](docs/setup.md)
- [Testing Strategy](docs/testing.md)
- [Database Schema](docs/database.md)

## License

Private repository - All rights reserved

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
