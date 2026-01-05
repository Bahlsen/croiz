import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/data/db/app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();
