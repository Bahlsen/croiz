import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:croiz/data/db/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    GeneratedPuzzles,
    PuzzleProgress,
    UserStatsTable,
    PuzzleStatsTable,
    UserAchievementsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4; // Incremented to recover from failed v3 migration

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Version 2: Added UserStatsTable and PuzzleStatsTable
      if (from < 2) {
        await m.createTable(userStatsTable);
        await m.createTable(puzzleStatsTable);
      }
      // Version 3: Added UserAchievementsTable
      if (from < 3) {
        await m.createTable(userAchievementsTable);
      }
      // Version 4: Recovery for potential failed v3 migration (tables missing but version bumped)
      if (from < 4) {
        try {
          await m.createTable(userStatsTable);
        } on Object catch (_) {
          // Ignore if exists
        }
        try {
          await m.createTable(puzzleStatsTable);
        } on Object catch (_) {
          // Ignore if exists
        }
        try {
          await m.createTable(userAchievementsTable);
        } on Object catch (_) {
          // Ignore if exists
        }
      }
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'croiz_db',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
