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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onBg = scheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading puzzle...',
                    style: TextStyle(
                      color: onBg,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      color: onBg.withAlpha((0.7 * 255).round()),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                key: const Key('menu_button'),
                icon: Icon(Icons.menu, color: onBg),
                onPressed: () => _showMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onBg = scheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            Center(
              child: Text(
                'Error loading puzzle id="$selectedId"',
                style: TextStyle(color: onBg),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                key: const Key('menu_button'),
                icon: Icon(Icons.menu, color: onBg),
                onPressed: () => _showMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
