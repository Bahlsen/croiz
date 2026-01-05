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
