import 'package:drift/drift.dart';

@TableIndex(name: 'puzzles_filter_idx', columns: {#difficulty, #language})
@TableIndex(name: 'puzzles_title_idx', columns: {#title})
class GeneratedPuzzles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get puzzleId => text().unique()();
  TextColumn get jsonPayload => text()();
  DateTimeColumn get createdAt => dateTime()();

  // Indexed fields for filtering
  IntColumn get difficulty => integer()();
  TextColumn get language => text()();
  TextColumn get title => text()();
}

class PuzzleProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get puzzleId => text().unique()();
  TextColumn get jsonPayload => text()();
  DateTimeColumn get lastPlayed => dateTime()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get completionPercent => integer().withDefault(const Constant(0))();
}

/// User statistics table - tracks overall game progress
class UserStatsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get totalPuzzlesCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalWordsFound => integer().withDefault(const Constant(0))();
  IntColumn get totalPlayTimeSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Puzzle statistics table - tracks individual puzzle completions
@TableIndex(name: 'puzzle_stats_puzzle_id_idx', columns: {#puzzleId})
@TableIndex(name: 'puzzle_stats_completed_at_idx', columns: {#completedAt})
class PuzzleStatsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get puzzleId => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get timeToCompleteSeconds => integer()();
  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();
  RealColumn get accuracy => real()(); // 0.0 - 1.0
  IntColumn get totalWords => integer()();
  IntColumn get wordsRevealed => integer().withDefault(const Constant(0))();
}

/// User achievements table - tracks unlocked achievements
class UserAchievementsTable extends Table {
  TextColumn get achievementId =>
      text()(); // Corresponds to AchievementId enum name
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {achievementId};
}
