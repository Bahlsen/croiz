import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/app_bar/crossword_app_bar.dart';

class CrosswordLoadingScaffold extends StatelessWidget {
  const CrosswordLoadingScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Colors.black,
    appBar: CrosswordAppBar(),
    body: SafeArea(
      bottom: true,
      top: false,
      child: Center(
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
              'Chargement du puzzle...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Patientez un instant',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

class CrosswordErrorScaffold extends StatelessWidget {
  const CrosswordErrorScaffold({required this.selectedId, Key? key})
    : super(key: key);
  final String selectedId;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: const CrosswordAppBar(),
    body: SafeArea(
      bottom: true,
      top: false,
      child: Center(
        child: Text(
          'Erreur au chargement du puzzle id="$selectedId"',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
