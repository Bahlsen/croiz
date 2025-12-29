import 'package:flutter_riverpod/flutter_riverpod.dart';

class EndGameOverlayVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

final endGameOverlayVisibleProvider =
    NotifierProvider<EndGameOverlayVisibleNotifier, bool>(
      EndGameOverlayVisibleNotifier.new,
    );
