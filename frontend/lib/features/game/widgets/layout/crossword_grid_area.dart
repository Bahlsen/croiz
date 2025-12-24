import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';

class CrosswordGridArea extends StatelessWidget {
  const CrosswordGridArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
    fit: FlexFit.loose,
    child: Padding(
      // Minimise top and horizontal spacing here. Keep a very small
      // horizontal inner padding so the grid doesn't overlap the
      // controls/banner below on tight layouts.
      padding: EdgeInsets.zero,
      child: Container(
        color: Colors.black,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: CrosswordGrid(),
        ),
      ),
    ),
  );
}
