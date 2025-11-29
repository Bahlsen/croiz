# Croiz REST API Documentation

Complete API documentation for the Croiz crossword game backend.

## Base URL

```
http://localhost:8080/api/v1
```

## Authentication

All endpoints except `/auth/register` and `/auth/login` require JWT authentication.

### Header Format

```
Authorization: Bearer <your_jwt_token>
```

### Token Expiration

- **Default**: 24 hours
- **Refresh**: Optional refresh token endpoint (to be implemented)

---

## Health Check Endpoint

### GET /health

Health check endpoint for monitoring.

**Response:**
```json
{
  "status": "UP",
  "service": "Croiz API",
  "version": "1.0.0"
}
```

**Status Codes:**
- `200 OK` - Service is healthy

---

## Authentication Endpoints

### POST /auth/register

Register a new user account.

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password123"
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "username": "john_doe",
  "email": "john@example.com",
  "total_games_played": 0,
  "games_won": 0,
  "total_score": 0
}
```

**Status Codes:**
- `201 Created` - User successfully created
- `400 Bad Request` - Invalid input or user already exists
- `409 Conflict` - Username or email already in use

**Validation Rules:**
- Username: 3-20 characters, alphanumeric + underscore
- Email: Valid email format
- Password: Minimum 8 characters

---

### POST /auth/login

Authenticate user and receive JWT token.

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "secure_password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "john_doe",
    "email": "john@example.com",
    "total_games_played": 25,
    "games_won": 12,
    "total_score": 4500
  },
  "expires_in": 86400
}
```

**Status Codes:**
- `200 OK` - Login successful
- `400 Bad Request` - Missing credentials
- `401 Unauthorized` - Invalid credentials

---

## Game Endpoints

### GET /games

List all available games with optional filtering.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 20)
- `difficulty` (optional): Filter by difficulty (1=Easy, 2=Medium, 3=Hard)
- `sort` (optional): Sort by field (default: created_at)

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "title": "Mots Croisés - Easy Level 1",
      "grid_size": 15,
      "difficulty": 1,
      "created_at": "2025-11-20T10:30:00Z"
    }
  ],
  "page": 1,
  "limit": 20,
  "total": 150
}
```

**Status Codes:**
- `200 OK` - Games retrieved successfully
- `401 Unauthorized` - Invalid or missing token
- `400 Bad Request` - Invalid query parameters

---

### GET /games/{id}

Get detailed information about a specific game.

**Path Parameters:**
- `id` (required): Game UUID

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "title": "Mots Croisés - Easy Level 1",
  "grid_size": 15,
  "difficulty": 1,
  "created_at": "2025-11-20T10:30:00Z"
}
```

**Status Codes:**
- `200 OK` - Game found
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - Game does not exist

---

### GET /games/{id}/board

Get the playable game board with grid and clues.

**Path Parameters:**
- `id` (required): Game UUID

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "title": "Mots Croisés - Easy Level 1",
  "grid": [
    ["E", "N", null, "C", "A", "R"],
    ["T", null, "P", "O", "U", "R"],
    ...
  ],
  "clues": {
    "1_across": "Alphabet letter",
    "1_down": "To move quickly",
    "2_across": "Personal pronoun",
    ...
  },
  "grid_size": 15,
  "difficulty": 1
}
```

**Status Codes:**
- `200 OK` - Board retrieved
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - Game not found

---

### POST /games/{id}/submit

Submit a completed game for scoring.

**Path Parameters:**
- `id` (required): Game UUID

**Request Body:**
```json
{
  "answers": {
    "1_across": "LETTRE",
    "1_down": "COURIR",
    "2_across": "MOI",
    ...
  },
  "time_taken_seconds": 300
}
```

**Response:**
```json
{
  "score": 950,
  "is_correct": true,
  "time_taken_seconds": 300,
  "user_stats": {
    "total_games_played": 26,
    "games_won": 13,
    "total_score": 5450
  }
}
```

**Status Codes:**
- `200 OK` - Submission processed
- `400 Bad Request` - Invalid answers
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - Game not found

---

### POST /games/{id}/hint

Request a hint for a specific clue.

**Path Parameters:**
- `id` (required): Game UUID

**Request Body:**
```json
{
  "clue_id": "1_across",
  "hint_type": "word_length"  // "word_length", "first_letter", "random_letter"
}
```

**Response:**
```json
{
  "clue_id": "1_across",
  "hint": "6 letters",
  "hint_type": "word_length"
}
```

**Status Codes:**
- `200 OK` - Hint provided
- `400 Bad Request` - Invalid clue or hint type
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - Game not found

---

### GET /games/{id}/leaderboard

Get top scores for a specific game.

**Path Parameters:**
- `id` (required): Game UUID

**Query Parameters:**
- `limit` (optional): Top N scores (default: 10)

**Response:**
```json
{
  "game_id": "550e8400-e29b-41d4-a716-446655440001",
  "game_title": "Mots Croisés - Easy Level 1",
  "leaderboard": [
    {
      "rank": 1,
      "username": "user1",
      "score": 1000,
      "time_taken_seconds": 180,
      "completed_at": "2025-11-25T10:30:00Z"
    },
    {
      "rank": 2,
      "username": "user2",
      "score": 950,
      "time_taken_seconds": 200,
      "completed_at": "2025-11-24T15:20:00Z"
    }
  ]
}
```

**Status Codes:**
- `200 OK` - Leaderboard retrieved
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - Game not found

---

## User Endpoints

### GET /users/{id}

Get user profile information.

**Path Parameters:**
- `id` (required): User UUID

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "username": "john_doe",
  "email": "john@example.com",
  "total_games_played": 25,
  "games_won": 12,
  "total_score": 4500,
  "created_at": "2025-11-01T00:00:00Z"
}
```

**Status Codes:**
- `200 OK` - User found
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found

---

### GET /users/{id}/stats

Get detailed user statistics and achievements.

**Path Parameters:**
- `id` (required): User UUID

**Response:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "total_games_played": 25,
  "games_won": 12,
  "win_rate": 48.0,
  "total_score": 4500,
  "average_score": 180,
  "average_time_seconds": 240,
  "total_time_seconds": 6000,
  "best_score": 1000,
  "worst_score": 85,
  "favorite_difficulty": 2,
  "last_played": "2025-11-25T14:30:00Z"
}
```

**Status Codes:**
- `200 OK` - Statistics retrieved
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found

---

### GET /users/{id}/games

Get user's game history.

**Path Parameters:**
- `id` (required): User UUID

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 20)
- `status` (optional): "completed", "in_progress"

**Response:**
```json
{
  "data": [
    {
      "game_id": "550e8400-e29b-41d4-a716-446655440001",
      "game_title": "Mots Croisés - Easy Level 1",
      "score": 950,
      "time_taken_seconds": 300,
      "completed_at": "2025-11-25T10:30:00Z"
    }
  ],
  "page": 1,
  "limit": 20,
  "total": 25
}
```

**Status Codes:**
- `200 OK` - Games retrieved
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found

---

### PUT /users/{id}

Update user profile.

**Path Parameters:**
- `id` (required): User UUID

**Request Body:**
```json
{
  "email": "newemail@example.com",
  "current_password": "secure_password123",
  "new_password": "new_secure_password456"
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "username": "john_doe",
  "email": "newemail@example.com",
  "total_games_played": 25,
  "games_won": 12,
  "total_score": 4500
}
```

**Status Codes:**
- `200 OK` - Profile updated
- `400 Bad Request` - Invalid data
- `401 Unauthorized` - Invalid or missing token
- `403 Forbidden` - Cannot update other user's profile
- `404 Not Found` - User not found

---

## Score Endpoints

### GET /scores/leaderboard

Get global leaderboard.

**Query Parameters:**
- `limit` (optional): Top N scores (default: 100)
- `period` (optional): "all_time", "monthly", "weekly" (default: "all_time")

**Response:**
```json
{
  "period": "all_time",
  "leaderboard": [
    {
      "rank": 1,
      "username": "pro_player",
      "total_score": 125000,
      "games_won": 500
    }
  ]
}
```

**Status Codes:**
- `200 OK` - Leaderboard retrieved
- `401 Unauthorized` - Invalid or missing token

---

### GET /scores/user/{id}

Get user's score history.

**Path Parameters:**
- `id` (required): User UUID

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 50)

**Response:**
```json
{
  "data": [
    {
      "game_id": "550e8400-e29b-41d4-a716-446655440001",
      "game_title": "Game 1",
      "score": 950,
      "completed_at": "2025-11-25T10:30:00Z"
    }
  ],
  "page": 1,
  "limit": 50,
  "total": 25
}
```

**Status Codes:**
- `200 OK` - Scores retrieved
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found

---

## Error Response Format

All errors follow this format:

```json
{
  "error": "ERROR_CODE",
  "message": "Human readable error message",
  "status": 400,
  "timestamp": "2025-11-25T10:30:00Z"
}
```

### Common Error Codes

| Code | Status | Meaning |
|------|--------|---------|
| INVALID_CREDENTIALS | 401 | Username/password incorrect |
| USER_NOT_FOUND | 404 | User does not exist |
| GAME_NOT_FOUND | 404 | Game does not exist |
| UNAUTHORIZED | 401 | Missing or invalid token |
| FORBIDDEN | 403 | Insufficient permissions |
| BAD_REQUEST | 400 | Invalid input data |
| CONFLICT | 409 | Resource already exists |
| INTERNAL_SERVER_ERROR | 500 | Server error |

---

## Rate Limiting

(To be implemented)

- Limit: 100 requests per minute per user
- Headers:
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 1700086400`

---

## Example Workflows

### Complete Game Workflow

```bash
# 1. Register user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "password123"
  }'

# 2. Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "password123"
  }'

# 3. Get games list
curl -X GET "http://localhost:8080/api/v1/games?difficulty=1" \
  -H "Authorization: Bearer <token>"

# 4. Get specific game board
curl -X GET "http://localhost:8080/api/v1/games/<game_id>/board" \
  -H "Authorization: Bearer <token>"

# 5. Submit completed game
curl -X POST "http://localhost:8080/api/v1/games/<game_id>/submit" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": {...},
    "time_taken_seconds": 300
  }'

# 6. Check leaderboard
curl -X GET "http://localhost:8080/api/v1/games/<game_id>/leaderboard" \
  -H "Authorization: Bearer <token>"

# 7. View user statistics
curl -X GET "http://localhost:8080/api/v1/users/<user_id>/stats" \
  -H "Authorization: Bearer <token>"
```

---

**Last Updated**: November 29, 2025
