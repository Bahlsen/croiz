import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/data/db/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
