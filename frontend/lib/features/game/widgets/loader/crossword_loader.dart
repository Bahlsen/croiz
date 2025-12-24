import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrosswordLoadingScaffold extends StatelessWidget {
  const CrosswordLoadingScaffold({Key? key}) : super(key: key);

  void _showMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/puzzles');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      bottom: true,
      top: false,
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading puzzle...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              key: const Key('menu_button'),
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _showMenu(context),
            ),
          ),
        ],
      ),
    ),
  );
}

class CrosswordErrorScaffold extends StatelessWidget {
  const CrosswordErrorScaffold({required this.selectedId, Key? key})
    : super(key: key);
  final String selectedId;

  void _showMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/puzzles');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      bottom: true,
      top: false,
      child: Stack(
        children: [
          Center(
            child: Text(
              'Error loading puzzle id="$selectedId"',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              key: const Key('menu_button'),
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _showMenu(context),
            ),
          ),
        ],
      ),
    ),
  );
}
