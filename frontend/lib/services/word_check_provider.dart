import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/services/word_check_service.dart';

/// Provider for answer validation service.
final wordCheckServiceProvider = Provider<WordCheckService>(
  (ref) => WordCheckService(),
);
