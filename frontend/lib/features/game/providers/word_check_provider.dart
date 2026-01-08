import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:croiz/features/game/services/word_check_service.dart';

part 'word_check_provider.g.dart';

/// Provider for answer validation service.
@Riverpod(keepAlive: true, dependencies: [])
WordCheckService wordCheckService(Ref ref) => WordCheckService();
