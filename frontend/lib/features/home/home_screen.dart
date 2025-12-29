import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croiz/services/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    Future<void> setLocale(String code) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', code);
      ref.read(localeProvider.notifier).setLocale(Locale(code));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(loc.appTitle),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: setLocale,
            icon: Icon(Icons.language, semanticLabel: loc.selectLanguage),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'en', child: Text(loc.languageEnglish)),
              PopupMenuItem(value: 'fr', child: Text(loc.languageFrench)),
              PopupMenuItem(value: 'uk', child: Text(loc.languageUkrainian)),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.welcome,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/puzzles'),
                  child: Text(loc.puzzles),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
