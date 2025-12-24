import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrosswordAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CrosswordAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Crossword'),
    backgroundColor: Colors.black,
    elevation: 0,
    // Reduce toolbar height to reclaim vertical space above the grid
    toolbarHeight: 40,
    leading: IconButton(
      tooltip: 'Puzzles',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.go('/puzzles'),
    ),
  );

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
