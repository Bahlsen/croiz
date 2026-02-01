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
  int get schemaVersion => 3; // Incremented for achievement tables

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
