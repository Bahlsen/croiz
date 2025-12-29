import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';

class CrosswordGridArea extends StatelessWidget {
  const CrosswordGridArea({super.key});

  @override
  Widget build(BuildContext context) => Flexible(
    fit: FlexFit.loose,
    child: Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const CrosswordGrid(),
    ),
  );
}
