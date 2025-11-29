import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';

class CrosswordScreen extends ConsumerWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Crossword'),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            color: Colors.black,
            child: const CrosswordGrid(),
          ),
        ),
      );
}
