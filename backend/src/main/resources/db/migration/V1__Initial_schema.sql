CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    total_games_played INTEGER NOT NULL DEFAULT 0,
    games_won INTEGER NOT NULL DEFAULT 0,
    total_score BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    grid_size INTEGER NOT NULL DEFAULT 15,
    difficulty INTEGER NOT NULL DEFAULT 1,
    grid_data TEXT,
    clues_data TEXT,
    created_at TIMESTAMP NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS game_scores (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    score INTEGER NOT NULL DEFAULT 0,
    time_taken_seconds INTEGER NOT NULL,
    completed_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_game FOREIGN KEY (game_id) REFERENCES games(id)
);

CREATE INDEX idx_user_username ON users(username);
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_game_scores_user ON game_scores(user_id);
CREATE INDEX idx_game_scores_game ON game_scores(game_id);
CREATE INDEX idx_game_active ON games(active);
