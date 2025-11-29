# Testing Strategy for Croiz

Comprehensive testing approach for the Croiz crossword game project.

## Testing Philosophy

```
Quality Gates:
- 80%+ code coverage
- All critical paths tested
- No unhandled exceptions
- Performance benchmarks met
```

## Test Pyramid

```
        ▲
       /│\         E2E & Integration Tests (10%)
      / │ \        Full workflow validation
     /  │  \
    /───┼───\      Widget & Integration Tests (20%)
   /    │    \     Component testing, API integration
  /─────┼─────\
 /      │      \   Unit Tests (70%)
/───────┼───────\  Business logic, utilities, algorithms
(unit tests for all layers)

Total coverage: 80%+
```

## Frontend Testing (Flutter)

### Unit Tests (70%)

**Purpose**: Test business logic, validators, calculations

**Files to Test:**
- `lib/domain/usecases/`
- `lib/services/` (business logic)
- `lib/data/models/` (serialization)
- Game algorithms, scoring logic

**Example:**

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameScoring', () {
    test('calculates correct score for perfect game', () {
      const baseScore = 100;
      const timeBonus = 50;
      const expectedScore = 150;
      
      final score = GameScoring.calculate(
        baseScore: baseScore,
        timeTaken: 300,
        difficulty: 1,
      );
      
      expect(score, equals(expectedScore));
    });

    test('validates word against clue', () {
      expect(WordValidator.isValid('LETTRE'), true);
      expect(WordValidator.isValid('123'), false);
      expect(WordValidator.isValid('café'), true); // French accents
    });

    test('detects crossword conflicts', () {
      final grid = GameBoard.empty(size: 15);
      grid.place('HELLO', position: (0, 0), direction: 'across');
      
      expect(() {
        grid.place('WORLD', position: (0, 4), direction: 'down');
      }, throwsException);
    });
  });
}
```

**Tools:**
- `test` package (built-in)
- `mockito` for mocking dependencies
- `mocktail` for modern mocking syntax

### Widget Tests (20%)

**Purpose**: Test UI components in isolation

**Files to Test:**
- `lib/features/*/screens/`
- `lib/features/*/widgets/`
- Custom widgets

**Example:**

```dart
void main() {
  group('GameBoardWidget', () {
    testWidgets('renders game board with grid', 
      (WidgetTester tester) async {
      const gameBoard = GameBoard(...);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameBoardWidget(gameBoard: gameBoard),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(GameCell), findsWidgets);
    });

    testWidgets('responds to cell taps', 
      (WidgetTester tester) async {
      // Test interaction logic
      await tester.tap(find.byType(GameCell).first);
      await tester.pumpAndSettle();
      
      // Verify state changed
      expect(find.byType(GameCell), findsWidgets);
    });

    testWidgets('highlights clue answers correctly', 
      (WidgetTester tester) async {
      // Test UI highlighting
    });
  });
}
```

**Tools:**
- `flutter_test` (built-in)
- `golden_toolkit` for UI regression testing
- `mocktail` for mocking providers

### Integration Tests (10%)

**Purpose**: Test complete gameplay flows end-to-end

**Files:**
- `integration_test/`

**Example:**

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Game Flow Integration Tests', () {
    testWidgets('Complete game from start to finish', 
      (WidgetTester tester) async {
      // Start app
      await app.main();
      await tester.pumpAndSettle();

      // Navigate to games list
      await tester.tap(find.byType(PlayButton));
      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byText('Easy Game 1'));
      await tester.pumpAndSettle();

      // Play game
      await tester.tap(find.byType(GameCell).first);
      await tester.typeText(find.byType(TextField), 'ANSWER');
      await tester.pumpAndSettle();

      // Submit game
      await tester.tap(find.byType(SubmitButton));
      await tester.pumpAndSettle();

      // Verify score screen
      expect(find.byType(ScoreScreen), findsOneWidget);
    });

    testWidgets('Handle network errors gracefully', 
      (WidgetTester tester) async {
      // Simulate network error
      MockDio.setError(DioException(...));
      
      // Verify error UI displayed
      expect(find.byType(ErrorWidget), findsOneWidget);
    });
  });
}
```

### Running Flutter Tests

```bash
cd frontend

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific file
flutter test test/unit/game_logic_test.dart

# Run widget tests only
flutter test --file test/widget/*.dart

# Watch mode
flutter test --watch

# Golden tests
flutter test test/widget/golden_tests.dart

# Generate HTML coverage report
flutter test --coverage && open coverage/index.html
```

### Test Coverage Goals

| Component | Target Coverage |
|-----------|-----------------|
| Business Logic | 90%+ |
| UI Widgets | 70%+ |
| Services | 85%+ |
| Models | 80%+ |
| Overall | 80%+ |

## Backend Testing (Spring Boot)

### Unit Tests (70%)

**Purpose**: Test service logic, validators, calculations

**Files to Test:**
- `src/main/java/com/croiz/service/`
- `src/main/java/com/croiz/entity/`
- Game algorithms, scoring logic

**Example:**

```java
@SpringBootTest
class GameServiceTest {

  @Mock
  private GameRepository gameRepository;

  @Mock
  private GameScoreRepository scoreRepository;

  @InjectMocks
  private GameService gameService;

  @BeforeEach
  void setUp() {
    MockitoAnnotations.openMocks(this);
  }

  @Test
  void testCalculateScore_PerfectGame() {
    int baseScore = 100;
    int timeTaken = 300;
    int difficulty = 1;
    
    int score = gameService.calculateScore(baseScore, timeTaken, difficulty);
    
    assertEquals(150, score);
  }

  @Test
  void testValidateAnswers_CorrectAnswers() {
    Map<String, String> answers = new HashMap<>();
    answers.put("1_across", "LETTRE");
    answers.put("1_down", "COURIR");
    
    Game game = new Game();
    game.setGridData("{...}");
    game.setCluesData("{...}");
    
    boolean isValid = gameService.validateAnswers(answers, game);
    assertTrue(isValid);
  }

  @Test
  void testValidateAnswers_IncorrectAnswers() {
    Map<String, String> answers = new HashMap<>();
    answers.put("1_across", "WRONG");
    
    boolean isValid = gameService.validateAnswers(answers, game);
    assertFalse(isValid);
  }
}
```

**Tools:**
- JUnit 5 (Jupiter)
- Mockito
- AssertJ (fluent assertions)

### Integration Tests (20%)

**Purpose**: Test controller + repository + database

**Files to Test:**
- `src/main/java/com/croiz/controller/`
- `src/main/java/com/croiz/repository/`

**Example:**

```java
@SpringBootTest
@AutoConfigureMockMvc
class GameControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private GameRepository gameRepository;

  @Test
  void testGetGames_ReturnsGameList() throws Exception {
    // Arrange
    Game game = new Game();
    game.setTitle("Test Game");
    gameRepository.save(game);

    // Act & Assert
    mockMvc.perform(get("/api/v1/games"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].title").value("Test Game"));
  }

  @Test
  void testSubmitGame_UpdatesUserStats() throws Exception {
    // Arrange
    String gameId = "test-game-id";
    String token = generateTestToken("user-id");
    
    SubmitGameRequest request = new SubmitGameRequest();
    request.setAnswers(validAnswers);
    request.setTimeTakenSeconds(300);

    // Act & Assert
    mockMvc.perform(
      post("/api/v1/games/{id}/submit", gameId)
          .header("Authorization", "Bearer " + token)
          .contentType(MediaType.APPLICATION_JSON)
          .content(objectMapper.writeValueAsString(request))
    )
    .andExpect(status().isOk())
    .andExpect(jsonPath("$.score").isNumber());
  }

  @Test
  void testUnauthorizedRequest_Returns401() throws Exception {
    mockMvc.perform(get("/api/v1/games"))
        .andExpect(status().isUnauthorized());
  }
}
```

**Tools:**
- MockMvc for controller testing
- TestRestTemplate for full HTTP testing
- @DataJpaTest for repository testing
- H2 in-memory database for isolation

### Repository Tests

```java
@DataJpaTest
class GameRepositoryTest {

  @Autowired
  private GameRepository gameRepository;

  @Test
  void testFindAllByActiveTrue() {
    // Arrange
    Game activeGame = new Game();
    activeGame.setActive(true);
    Game inactiveGame = new Game();
    inactiveGame.setActive(false);
    
    gameRepository.saveAll(List.of(activeGame, inactiveGame));

    // Act
    List<Game> result = gameRepository.findAllByActiveTrue();

    // Assert
    assertEquals(1, result.size());
    assertTrue(result.get(0).getActive());
  }

  @Test
  void testFindByDifficulty() {
    Game easyGame = new Game();
    easyGame.setDifficulty(1);
    gameRepository.save(easyGame);

    List<Game> result = gameRepository.findByDifficulty(1);
    
    assertEquals(1, result.size());
  }
}
```

### Running Backend Tests

```bash
cd backend

# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests GameServiceTest

# Run specific test method
./gradlew test --tests GameServiceTest.testCalculateScore*

# Generate coverage report
./gradlew test jacocoTestReport

# View coverage
open build/reports/jacoco/test/html/index.html

# Run with verbose output
./gradlew test --info

# Continue tests after failure
./gradlew test --continue
```

### Test Coverage Goals

| Component | Target Coverage |
|-----------|-----------------|
| Controllers | 85%+ |
| Services | 90%+ |
| Repositories | 80%+ |
| Entities | 70%+ |
| Overall | 80%+ |

## Test Configuration

### Frontend: analysis_options.yaml

```yaml
analyzer:
  exclude:
    - '**/*.g.dart'
  errors:
    missing_required_param: error
    missing_return: error
```

### Backend: application-test.yaml

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: create-drop
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password:
  h2:
    console:
      enabled: true

logging:
  level:
    root: WARN
    com.croiz: DEBUG
```

## CI/CD Test Pipeline

### GitHub Actions Workflow

```yaml
- name: Run tests
  run: |
    # Frontend
    cd frontend && flutter test --coverage
    
    # Backend
    cd ../backend && ./gradlew test jacocoTestReport

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./frontend/coverage/lcov.info,./backend/build/reports/jacoco/test/jacocoTestReport.xml
    flags: flutter,backend
```

## Test Metrics & Reporting

### Coverage Reports

```bash
# Frontend coverage
flutter test --coverage
# Generated: coverage/lcov.info
# HTML: open coverage/index.html

# Backend coverage
./gradlew jacocoTestReport
# Generated: build/reports/jacoco/test/jacocoTestReport.xml
# HTML: open build/reports/jacoco/test/html/index.html
```

### Test Results

```
=== Flutter Test Results ===
Unit Tests: 45/45 passed (100%)
Widget Tests: 20/20 passed (100%)
Coverage: 85%

=== Backend Test Results ===
Unit Tests: 60/60 passed (100%)
Integration Tests: 15/15 passed (100%)
Coverage: 82%
```

## Performance Testing

```bash
# Flutter performance
flutter test --trace-startup

# Backend load testing (optional)
# Using Apache JMeter or Gatling
```

## Testing Checklist

### Before Commit

- [ ] All unit tests pass
- [ ] Coverage > 80%
- [ ] Code analysis clean
- [ ] Integration tests pass
- [ ] No hardcoded values/secrets in tests

### Before PR Merge

- [ ] All CI/CD checks pass
- [ ] Code reviewed by peer
- [ ] Manual testing in staging
- [ ] No regression in main features

## Best Practices

1. **Test Naming**: Describe what is being tested
   ```
   testCalculateScore_WithPerfectGame_ReturnsMaxScore()
   test_scoreCalculation_perfect_game()
   ```

2. **Test Isolation**: Each test should be independent
   ```dart
   setUp() { /* Initialize test data */ }
   tearDown() { /* Clean up */ }
   ```

3. **Mock External Dependencies**
   ```
   Mock: API calls, Database, FileSystem, Random
   Don't Mock: Business logic, Entities, Models
   ```

4. **Use Fixtures**: Create reusable test data
   ```dart
   final testGame = GameFixture.easyGame();
   final testUser = UserFixture.validUser();
   ```

5. **Assert Behavior, Not Implementation**
   ```
   Good: expect(score, equals(100));
   Bad: expect(scoreCalculated, true);
   ```

---

**Last Updated**: November 29, 2025
