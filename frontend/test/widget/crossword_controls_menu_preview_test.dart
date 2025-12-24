import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu_preview.dart';

void main() {
  testWidgets('Menu preview shows menu items', (tester) async {
    await tester.pumpWidget(const CrosswordControlsMenuPreview());
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Keyboard style'), findsOneWidget);
    expect(find.text('Mute sounds'), findsOneWidget);
    expect(find.text('Dark theme'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
  });
}
