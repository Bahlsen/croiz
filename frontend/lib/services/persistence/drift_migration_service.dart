import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for migrating data from Hive to Drift.
///
/// NOTE: Hive dependencies have been removed from the project.
/// This service is now a no-op/stub that logs a message.
/// If migration from old Hive data is required, re-add Hive dependencies
/// and restore the logic from git history.
class DriftMigrationService {
  DriftMigrationService(this.ref);

  final Ref ref;

  /// Performs the migration from Hive to Drift.
  ///
  /// This implementation is a STUB.
  Future<void> runMigrationIfNeeded() async {
    // Hive is no longer available.
    // print('Migration skipped: Hive dependencies removed.');
  }
}

final driftMigrationServiceProvider = Provider<DriftMigrationService>(
  DriftMigrationService.new,
);
