import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';
import 'package:croiz/features/game/game_providers.dart';

class CrosswordScreen extends ConsumerWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editMode = ref.watch(editModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crossword'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(editMode ? Icons.edit_off : Icons.edit, color: Colors.white),
            tooltip: editMode ? 'Exit edit mode' : 'Enter edit mode',
            onPressed: () => ref.read(editModeProvider.notifier).state = !editMode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          color: Colors.black,
          child: const CrosswordGrid(),
        ),
      ),
    );
  }
}
