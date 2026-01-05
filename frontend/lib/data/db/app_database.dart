import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:croiz/data/db/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [GeneratedPuzzles, PuzzleProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'croiz_db',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
