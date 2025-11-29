# Croiz Project Architecture

Comprehensive architecture documentation for the Croiz crossword game project.

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Mobile Client (Flutter)                   │
│  Riverpod State Management • Dio HTTP Client • Sqflite Cache │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼ HTTP REST API
┌──────────────────────────────────────────────────────────────┐
│              Spring Boot REST API (8080)                      │
│  Spring Security + JWT • Spring Data JPA • PostgreSQL         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼ JDBC
┌──────────────────────────────────────────────────────────────┐
│            PostgreSQL Database (5432)                         │
│  Users • Games • GameScores • Indexes & Migrations            │
└──────────────────────────────────────────────────────────────┘
```

## Frontend Architecture (Flutter + Riverpod)

### Layered Architecture

```
Presentation Layer
├── Screens (Game, Home, Auth)
├── Widgets (GameBoard, Clues, UserProfile)
└── Theme & Styling

State Management Layer (Riverpod)
├── Providers (AppProviders, GameProviders, UserProviders)
├── StateNotifiers (GameNotifier, AuthNotifier)
└── FutureProviders (Data fetching)

Domain Layer
├── Entities (GameEntity, Player, GameScore)
└── Use Cases (business logic)

Data Layer
├── Repositories (GameRepository, UserRepository)
├── Models (DTO for serialization)
├── Data Sources
│   ├── Remote (API via Dio)
│   └── Local (Sqflite, SharedPreferences)
└── Services (HTTP, Cache, Storage)
```

### Directory Structure

```
frontend/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/
│   │   ├── constants.dart           # App-wide constants
│   │   ├── theme.dart               # UI themes
│   │   └── exceptions.dart          # Custom exceptions
│   ├── services/
│   │   ├── providers.dart           # Riverpod providers
│   │   ├── api_service.dart         # HTTP client setup
│   │   └── secure_storage.dart      # Token management
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   ├── providers/
│   │   │   └── models/
│   │   ├── game/
│   │   │   ├── screens/
│   │   │   │   ├── game_screen.dart
│   │   │   │   └── game_board_widget.dart
│   │   │   ├── providers/
│   │   │   │   └── game_provider.dart
│   │   │   └── models/
│   │   │       └── game_state.dart
│   │   └── home/
│   │       ├── screens/
│   │       ├── providers/
│   │       └── widgets/
│   ├── data/
│   │   ├── models/
│   │   │   ├── game_model.dart
│   │   │   └── user_model.dart
│   │   ├── repositories/
│   │   │   ├── game_repository.dart
│   │   │   └── user_repository.dart
│   │   └── datasources/
│   │       ├── remote/
│   │       │   └── api_client.dart
│   │       └── local/
│   │           └── database.dart
│   └── domain/
│       ├── entities/
│       │   └── game_entities.dart
│       └── usecases/
│           └── game_usecases.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
└── analysis_options.yaml
```

### State Management Flow (Riverpod)

```
User Interaction (Widget)
         │
         ▼
   Riverpod Provider notified
         │
         ▼
StateNotifier updates state
         │
         ▼
   Repository called
         │
         ▼
   HTTP Request / Database Query
         │
         ▼
   Response received
         │
         ▼
   State updated
         │
         ▼
   Widget rebuilds with new state
```

### Key Riverpod Providers

```dart
// Authentication
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>;

// Game State
final gameStateProvider = StateNotifierProvider<GameNotifier, AsyncValue<GameState>>;

// Current Game Data
final currentGameProvider = FutureProvider<GameBoard>(...);

// User Statistics
final userStatsProvider = FutureProvider<UserStats>(...);

// HTTP Client
final dioProvider = Provider<Dio>(...);

// Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>(...);
```

## Backend Architecture (Spring Boot)

### Layered Architecture

```
REST Controller Layer
├── AuthController
├── GameController
├── UserController
└── ScoreController
          │
          ▼
Service Layer (Business Logic)
├── AuthService
├── GameService
├── UserService
└── ScoreService
          │
          ▼
Repository Layer (Data Access)
├── UserRepository (Spring Data JPA)
├── GameRepository
└── GameScoreRepository
          │
          ▼
Entity/Model Layer
├── User
├── Game
└── GameScore
          │
          ▼
PostgreSQL Database
```

### Directory Structure

```
backend/
├── src/main/java/com/croiz/
│   ├── CroizApiApplication.java     # Entry point
│   ├── controller/
│   │   ├── HealthController.java
│   │   ├── AuthController.java      # (to implement)
│   │   ├── GameController.java      # (to implement)
│   │   └── UserController.java      # (to implement)
│   ├── service/
│   │   ├── AuthService.java         # (to implement)
│   │   ├── GameService.java         # (to implement)
│   │   └── UserService.java         # (to implement)
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── GameRepository.java
│   │   └── GameScoreRepository.java
│   ├── entity/
│   │   ├── User.java
│   │   ├── Game.java
│   │   └── GameScore.java
│   ├── dto/
│   │   ├── UserDto.java
│   │   ├── LoginRequest.java
│   │   ├── LoginResponse.java
│   │   └── GameDto.java             # (to implement)
│   ├── security/
│   │   ├── JwtTokenProvider.java    # (to implement)
│   │   ├── JwtAuthFilter.java       # (to implement)
│   │   └── SecurityConfig.java      # (to implement)
│   ├── config/
│   │   ├── CorsConfig.java
│   │   └── DatabaseConfig.java      # (optional)
│   └── exception/
│       ├── ResourceNotFoundException.java
│       └── GlobalExceptionHandler.java
├── src/main/resources/
│   ├── application.yaml
│   ├── application-test.yaml
│   └── db/migration/
│       └── V1__Initial_schema.sql
├── src/test/java/com/croiz/
│   ├── controller/
│   │   └── HealthControllerTest.java
│   └── service/
│       └── (Service tests to implement)
└── build.gradle
```

### REST API Endpoint Structure

```
Base URL: http://localhost:8080/api/v1

Health
├── GET /health                  # Application health

Authentication (To implement)
├── POST /auth/register          # Register new user
├── POST /auth/login             # Login with username/password
└── POST /auth/refresh           # Refresh JWT token

Games (To implement)
├── GET /games                   # List all games
├── POST /games                  # Create new game (admin)
├── GET /games/{id}              # Get game details
├── GET /games/{id}/board        # Get playable board
└── GET /games/{difficulty}      # Filter by difficulty

Game Play (To implement)
├── POST /games/{id}/submit      # Submit answer
├── POST /games/{id}/hint        # Request hint
└── GET /games/{id}/leaderboard  # Top scores

User Statistics (To implement)
├── GET /users/{id}              # Get user profile
├── GET /users/{id}/stats        # Get user statistics
├── GET /users/{id}/games        # User game history
└── PUT /users/{id}              # Update profile

Scores (To implement)
├── GET /scores/leaderboard      # Global leaderboard
├── GET /scores/user/{id}        # User's scores
└── GET /scores/game/{id}        # Game's top scores
```

### Data Flow Example: Login

```
Mobile Client (Flutter)
    │
    ├─ User enters credentials
    │
    └─ Calls authProvider.login(username, password)
                    │
                    ▼
Flutter Auth Service
    │
    └─ POST /api/v1/auth/login with credentials
                    │
                    ▼
Spring Boot AuthController
    │
    ├─ Validates input
    │
    └─ Calls authService.authenticate()
                    │
                    ▼
AuthService
    │
    ├─ Finds user by username
    │
    ├─ Validates password (BCrypt)
    │
    └─ Generates JWT token (24h expiration)
                    │
                    ▼
Returns LoginResponse with token + user data
                    │
                    ▼
Flutter stores token securely (flutter_secure_storage)
    │
    └─ Updates authProvider state
                    │
                    ▼
UI navigates to home screen
    │
    └─ All subsequent requests include token in Authorization header
```

## Database Schema

### Users Table

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,  -- BCrypt hashed
    total_games_played INTEGER NOT NULL DEFAULT 0,
    games_won INTEGER NOT NULL DEFAULT 0,
    total_score BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true
);

CREATE INDEX idx_user_username ON users(username);
CREATE INDEX idx_user_email ON users(email);
```

### Games Table

```sql
CREATE TABLE games (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    grid_size INTEGER NOT NULL DEFAULT 15,
    difficulty INTEGER NOT NULL DEFAULT 1,  -- 1=Easy, 2=Medium, 3=Hard
    grid_data TEXT NOT NULL,  -- JSON format
    clues_data TEXT NOT NULL,  -- JSON format
    created_at TIMESTAMP NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true
);

CREATE INDEX idx_game_active ON games(active);
CREATE INDEX idx_game_difficulty ON games(difficulty);
```

### GameScores Table

```sql
CREATE TABLE game_scores (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    score INTEGER NOT NULL DEFAULT 0,
    time_taken_seconds INTEGER NOT NULL,
    completed_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_game_scores_user ON game_scores(user_id);
CREATE INDEX idx_game_scores_game ON game_scores(game_id);
CREATE INDEX idx_game_scores_completed ON game_scores(completed_at DESC);
```

## Security Architecture

### Authentication Flow

```
┌────────────────────────────────────────────────────┐
│ Mobile App (Flutter)                               │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼
        1. POST /auth/login (username, password)
                      │
                      ▼
┌────────────────────────────────────────────────────┐
│ Spring Boot Backend                                │
│ - Hash password with BCrypt                        │
│ - Compare with stored hash                         │
│ - Generate JWT token with user claims              │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼
        2. Return JWT token + user data
                      │
                      ▼
┌────────────────────────────────────────────────────┐
│ Mobile App (Flutter)                               │
│ - Store token in flutter_secure_storage            │
│ - Add to Authorization header on requests          │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼
        3. GET /games (with Authorization: Bearer <token>)
                      │
                      ▼
┌────────────────────────────────────────────────────┐
│ Spring Boot Backend                                │
│ JwtAuthFilter:                                     │
│ - Extract token from header                        │
│ - Validate signature                               │
│ - Check expiration                                 │
│ - Set Spring Security context                      │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼
        4. Process request with authenticated user
```

### Token Structure

```
JWT Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload (Claims):
{
  "sub": "user_id",
  "username": "john_doe",
  "email": "john@example.com",
  "iat": 1700000000,
  "exp": 1700086400
}

Signature: HMACSHA256(header + payload, secret)
```

## Deployment Architecture

```
GitHub Repository (Private)
    │
    ├─ develop branch → Staging environment
    │
    ├─ main branch → Production
    │
    └─ feature/* branches → PR reviews
            │
            ▼
    GitHub Actions CI/CD
        │
        ├─ flutter-tests.yml
        │   ├─ flutter analyze
        │   ├─ flutter test --coverage
        │   └─ Build APK
        │
        ├─ api-tests.yml
        │   ├─ ./gradlew test
        │   ├─ ./gradlew spotlessCheck
        │   ├─ Generate coverage
        │   └─ Build JAR
        │
        ├─ integration-tests.yml
        │   └─ End-to-end tests
        │
        └─ deploy.yml (on release)
            ├─ Build & push Docker image
            ├─ Deploy to container registry
            └─ Update production environment
```

## Performance Considerations

### Frontend
- Lazy loading of game boards
- Image caching with Dio
- State preservation with Riverpod
- Efficient widget rebuilds (const constructors)
- Local database caching to reduce API calls

### Backend
- Connection pooling (HikariCP)
- Database indexes on frequently queried columns
- Pagination for list endpoints
- Cache commonly accessed data
- Async processing for scoring calculations

### Database
- Foreign key constraints with indices
- Composite indices for complex queries
- Regular VACUUM and ANALYZE
- Connection pooling at application level
- Write-ahead logging (PostgreSQL default)

## Monitoring & Logging

### Backend Logging

```
Levels:
- ROOT: INFO
- com.croiz: DEBUG
- org.springframework.web: INFO
- org.springframework.security: DEBUG
- org.hibernate: WARN
```

### Frontend Logging

```
- Dio HTTP requests/responses
- State changes in Riverpod
- Error handling and exceptions
- Performance metrics
```

### Metrics (Actuator)

```
GET /actuator/health              # Health check
GET /actuator/metrics             # Application metrics
GET /actuator/metrics/http.requests.total
```

## Future Architecture Enhancements

1. **Caching Layer**
   - Redis for session cache
   - Distributed cache for frequently accessed games

2. **Message Queue**
   - RabbitMQ/Kafka for async scoring
   - Notification system for achievements

3. **Search Engine**
   - Elasticsearch for game search
   - Full-text search on clues/words

4. **Analytics**
   - Track user engagement
   - Game difficulty adjustment
   - Performance monitoring

5. **Microservices** (if scaling)
   - Authentication service
   - Game service
   - Scoring service
   - User service

---

**Last Updated**: November 29, 2025
