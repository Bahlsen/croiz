import 'package:flutter/material.dart';
import 'crossword_controls_menu.dart';

/// Small preview widget for the menu overlay. Use this in the app or
/// run the widget test to quickly preview the UI.
class CrosswordControlsMenuPreview extends StatelessWidget {
  const CrosswordControlsMenuPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Menu Preview')),
      body: Stack(
        children: [
          // Background content to demonstrate the blur
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 20,
            itemBuilder: (context, i) => ListTile(title: Text('Item #$i')),
          ),

          // Always show the menu in preview
          CrosswordControlsMenu(
            onClose: () {
              // In preview just pop the route if present
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    ),
  );
}
