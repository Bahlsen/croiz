import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';

class CrosswordGridArea extends StatelessWidget {
  const CrosswordGridArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
    fit: FlexFit.loose,
    child: Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 0),
      child: Container(color: Colors.black, child: const CrosswordGrid()),
    ),
  );
}
