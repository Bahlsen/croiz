# Spring Boot Backend

## Overview

The Croiz Spring Boot API provides a RESTful backend for the crossword game, handling authentication, game management, user statistics, and scoring systems.

## Architecture

### Layered Architecture

```
Controller (REST Endpoints)
        ↓
   Service (Business Logic)
        ↓
   Repository (Data Access)
        ↓
   Entity (JPA Models)
        ↓
   Database (PostgreSQL)
```

### Directory Structure

```
src/main/java/com/croiz/
├── CroizApiApplication.java    # Entry point
├── controller/                  # REST endpoints
├── service/                     # Business logic
├── repository/                  # Data access
├── entity/                      # JPA entities
├── dto/                         # Data transfer objects
├── security/                    # Security configuration
├── config/                      # App configuration
└── exception/                   # Exception handling

src/main/resources/
├── application.yaml            # Configuration
├── application-test.yaml       # Test configuration
└── db/migration/               # Flyway migrations
```

## Technology Stack

- **Framework**: Spring Boot 4.0.1
- **Database**: PostgreSQL
- **Build Tool**: Gradle 8.5
- **Testing**: JUnit 5, MockMvc, H2 (in-memory)
- **Authentication**: Spring Security + JWT
- **Migrations**: Flyway
- **Code Quality**: Spotless, JaCoCo

## API Endpoints

### Health Check
```
GET /api/v1/health
```

### Authentication (to be implemented)
```
POST /api/v1/auth/register    # Register new user
POST /api/v1/auth/login       # Login user
```

### Games (to be implemented)
```
GET    /api/v1/games          # List all games
POST   /api/v1/games          # Create new game
GET    /api/v1/games/{id}     # Get game details
GET    /api/v1/games/{id}/board  # Get game board
```

### Scores (to be implemented)
```
GET    /api/v1/games/{id}/scores   # Get game scores
POST   /api/v1/games/{id}/submit   # Submit game answer
GET    /api/v1/users/{id}/stats    # Get user statistics
```

## Database Schema

### Users Table
- `id` - UUID primary key
- `username` - Unique username
- `email` - Unique email
- `password` - Hashed password
- `total_games_played` - Counter
- `games_won` - Counter
- `total_score` - Cumulative score
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp
- `enabled` - Active status

### Games Table
- `id` - UUID primary key
- `title` - Game title
- `grid_size` - Grid dimensions (default 15x15)
- `difficulty` - 1=Easy, 2=Medium, 3=Hard
- `grid_data` - JSON grid data
- `clues_data` - JSON clues
- `created_at` - Creation timestamp
- `active` - Active status

### GameScores Table
- `id` - UUID primary key
- `user_id` - FK to users
- `game_id` - FK to games
- `score` - Points earned
- `time_taken_seconds` - Duration
- `completed_at` - Completion timestamp

## Security

### JWT Authentication

Spring Security is configured with JWT tokens:
- Tokens are issued on successful login
- Tokens are validated on each request
- Token expiration: Configurable (default 24 hours)
- Refresh tokens: To be implemented

### CORS Configuration

CORS is enabled for:
- Local development (http://localhost:3000, http://localhost:8080)
- Flutter mobile client
- Headers: All standard headers allowed
- Credentials: Supported

## Configuration

### Environment Variables

```yaml
# Database
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/croiz
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=postgres

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRATION=86400000  # 24 hours in milliseconds
```

### Profiles

- **default** - Development with PostgreSQL
- **test** - Testing with H2 in-memory database
- **prod** - Production configuration

## Testing

### Test Pyramid

- **70% Unit Tests** - Service logic, validators
- **20% Integration Tests** - Controller + Repository
- **10% End-to-End Tests** - Full API flows

### Running Tests

```bash
# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests HealthControllerTest

# Generate coverage report
./gradlew test jacocoTestReport

# Check code quality
./gradlew checkCodeQuality

# Format code
./gradlew spotlessApply
```

### Test Configuration

Tests use:
- H2 in-memory database (faster, isolated)
- MockMvc for controller testing
- Mockito for service mocking
- `application-test.yaml` for test properties

## Build & Run

### Development

```bash
# Build project
./gradlew build

# Run application
./gradlew bootRun

# Watch mode (with DevTools)
./gradlew bootRun --args='--spring.devtools.restart.enabled=true'
```

### Production

```bash
# Build JAR
./gradlew bootJar

# Run JAR
java -jar build/libs/croiz-api-1.0.0.jar
```

### Docker

```bash
# Build Docker image
docker build -t croiz-api:1.0.0 .

# Run container
docker run -e SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/croiz \
           -e SPRING_DATASOURCE_PASSWORD=postgres \
           -p 8080:8080 \
           croiz-api:1.0.0
```

## Database Migrations

Flyway automatically runs SQL migrations from `src/main/resources/db/migration/`:

- **V1__Initial_schema.sql** - Creates users, games, and game_scores tables

### Adding New Migrations

1. Create file: `V2__Add_your_feature.sql`
2. Write migration SQL
3. Flyway runs automatically on startup

## Performance Considerations

- Database indexes on frequently queried fields
- Connection pooling (HikariCP)
- Caching strategies (Spring Cache)
- Query optimization (N+1 prevention)

## Logging

- **Root level**: INFO
- **Application level**: DEBUG
- **Spring Web**: INFO
- **Spring Security**: DEBUG

Configure via `application.yaml`:
```yaml
logging:
  level:
    com.croiz: DEBUG
```

## CI/CD Integration

GitHub Actions automatically:
- Runs tests (`./gradlew test`)
- Checks code quality (`./gradlew checkCodeQuality`)
- Generates coverage reports
- Builds JAR artifact

See `.github/workflows/api-tests.yml`

## Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Data JPA](https://spring.io/projects/spring-data-jpa)
- [Spring Security](https://spring.io/projects/spring-security)
- [Flyway Migrations](https://flywaydb.org/documentation/getstarted/how)
