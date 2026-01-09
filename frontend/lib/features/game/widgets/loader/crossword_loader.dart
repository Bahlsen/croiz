import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrosswordLoadingScaffold extends StatelessWidget {
  const CrosswordLoadingScaffold({super.key});

  void _showMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(AppLocalizations.of(context)?.home ?? 'Home'),
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
                    AppLocalizations.of(context)?.loadingPuzzle ??
                        'Loading puzzle...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onBg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.pleaseWait ?? 'Please wait',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onBg.withAlpha(178), // 70% opacity
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
                tooltip: AppLocalizations.of(context)?.menu ?? 'Menu',
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
  const CrosswordErrorScaffold({
    required this.selectedId,
    this.error,
    this.stackTrace,
    super.key,
  });
  final String selectedId;
  final Object? error;
  final StackTrace? stackTrace;

  void _showMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(AppLocalizations.of(context)?.home ?? 'Home'),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: scheme.error),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.errorLoading ??
                          'Error loading puzzle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onBg,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puzzle ID: $selectedId',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onBg.withAlpha(178), // 70% opacity
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          error.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: scheme.onErrorContainer,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/puzzles'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Puzzles'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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
