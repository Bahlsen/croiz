// ignore_for_file: avoid_print

import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/fill_dictionary_service.dart';
import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Multi-language generation test
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Theme words per language (simulating Gemini)
  final languageWords = <String, List<GeneratedWord>>{
    'en': [
      const GeneratedWord(answer: 'COMPUTER', clue: 'Electronic device'),
      const GeneratedWord(answer: 'SOFTWARE', clue: 'Programs'),
      const GeneratedWord(answer: 'KEYBOARD', clue: 'Input device'),
      const GeneratedWord(answer: 'MONITOR', clue: 'Display'),
      const GeneratedWord(answer: 'INTERNET', clue: 'Global network'),
      const GeneratedWord(answer: 'PROGRAMMING', clue: 'Coding'),
      const GeneratedWord(answer: 'ALGORITHM', clue: 'Step by step'),
      const GeneratedWord(answer: 'DATABASE', clue: 'Data storage'),
      const GeneratedWord(answer: 'NETWORK', clue: 'Connected systems'),
      const GeneratedWord(answer: 'SECURITY', clue: 'Protection'),
      const GeneratedWord(answer: 'CODE', clue: 'Instructions'),
      const GeneratedWord(answer: 'DATA', clue: 'Information'),
      const GeneratedWord(answer: 'FILE', clue: 'Document'),
      const GeneratedWord(answer: 'USER', clue: 'Person using'),
      const GeneratedWord(answer: 'SYSTEM', clue: 'Organized set'),
      const GeneratedWord(answer: 'PROCESSOR', clue: 'CPU'),
      const GeneratedWord(answer: 'MEMORY', clue: 'RAM'),
      const GeneratedWord(answer: 'STORAGE', clue: 'Hard drive'),
      const GeneratedWord(answer: 'BROWSER', clue: 'Web viewer'),
      const GeneratedWord(answer: 'SEARCH', clue: 'Find'),
    ],
    'fr': [
      const GeneratedWord(answer: 'ORDINATEUR', clue: 'Appareil electronique'),
      const GeneratedWord(answer: 'LOGICIEL', clue: 'Programme'),
      const GeneratedWord(answer: 'CLAVIER', clue: 'Peripherique'),
      const GeneratedWord(answer: 'ECRAN', clue: 'Affichage'),
      const GeneratedWord(answer: 'INTERNET', clue: 'Reseau mondial'),
      const GeneratedWord(answer: 'PROGRAMMATION', clue: 'Codage'),
      const GeneratedWord(answer: 'ALGORITHME', clue: 'Etapes'),
      const GeneratedWord(answer: 'DONNEES', clue: 'Informations'),
      const GeneratedWord(answer: 'RESEAU', clue: 'Systemes connectes'),
      const GeneratedWord(answer: 'SECURITE', clue: 'Protection'),
      const GeneratedWord(answer: 'CODE', clue: 'Instructions'),
      const GeneratedWord(answer: 'FICHIER', clue: 'Document'),
      const GeneratedWord(answer: 'UTILISATEUR', clue: 'Personne'),
      const GeneratedWord(answer: 'SYSTEME', clue: 'Ensemble'),
      const GeneratedWord(answer: 'PROCESSEUR', clue: 'CPU'),
      const GeneratedWord(answer: 'MEMOIRE', clue: 'RAM'),
      const GeneratedWord(answer: 'STOCKAGE', clue: 'Disque dur'),
      const GeneratedWord(answer: 'NAVIGATEUR', clue: 'Web'),
      const GeneratedWord(answer: 'RECHERCHE', clue: 'Trouver'),
      const GeneratedWord(answer: 'APPLICATION', clue: 'App'),
    ],
    'es': [
      const GeneratedWord(answer: 'ORDENADOR', clue: 'Dispositivo'),
      const GeneratedWord(answer: 'PROGRAMA', clue: 'Software'),
      const GeneratedWord(answer: 'TECLADO', clue: 'Entrada'),
      const GeneratedWord(answer: 'PANTALLA', clue: 'Display'),
      const GeneratedWord(answer: 'INTERNET', clue: 'Red global'),
      const GeneratedWord(answer: 'PROGRAMACION', clue: 'Codificacion'),
      const GeneratedWord(answer: 'ALGORITMO', clue: 'Pasos'),
      const GeneratedWord(answer: 'DATOS', clue: 'Informacion'),
      const GeneratedWord(answer: 'SEGURIDAD', clue: 'Proteccion'),
      const GeneratedWord(answer: 'CODIGO', clue: 'Instrucciones'),
      const GeneratedWord(answer: 'ARCHIVO', clue: 'Documento'),
      const GeneratedWord(answer: 'USUARIO', clue: 'Persona'),
      const GeneratedWord(answer: 'SISTEMA', clue: 'Conjunto'),
      const GeneratedWord(answer: 'PROCESADOR', clue: 'CPU'),
      const GeneratedWord(answer: 'MEMORIA', clue: 'RAM'),
      const GeneratedWord(answer: 'ALMACENAMIENTO', clue: 'Disco'),
      const GeneratedWord(answer: 'NAVEGADOR', clue: 'Web'),
      const GeneratedWord(answer: 'BUSQUEDA', clue: 'Encontrar'),
      const GeneratedWord(answer: 'APLICACION', clue: 'App'),
      const GeneratedWord(answer: 'DESARROLLO', clue: 'Development'),
    ],
    'de': [
      const GeneratedWord(answer: 'COMPUTER', clue: 'Geraet'),
      const GeneratedWord(answer: 'SOFTWARE', clue: 'Programm'),
      const GeneratedWord(answer: 'TASTATUR', clue: 'Eingabe'),
      const GeneratedWord(answer: 'BILDSCHIRM', clue: 'Anzeige'),
      const GeneratedWord(answer: 'INTERNET', clue: 'Netzwerk'),
      const GeneratedWord(answer: 'PROGRAMMIERUNG', clue: 'Codierung'),
      const GeneratedWord(answer: 'ALGORITHMUS', clue: 'Schritte'),
      const GeneratedWord(answer: 'DATENBANK', clue: 'Speicher'),
      const GeneratedWord(answer: 'NETZWERK', clue: 'Verbunden'),
      const GeneratedWord(answer: 'SICHERHEIT', clue: 'Schutz'),
      const GeneratedWord(answer: 'DATEI', clue: 'Dokument'),
      const GeneratedWord(answer: 'BENUTZER', clue: 'Person'),
      const GeneratedWord(answer: 'SYSTEM', clue: 'Zusammen'),
      const GeneratedWord(answer: 'PROZESSOR', clue: 'CPU'),
      const GeneratedWord(answer: 'SPEICHER', clue: 'RAM'),
      const GeneratedWord(answer: 'FESTPLATTE', clue: 'Disk'),
      const GeneratedWord(answer: 'BROWSER', clue: 'Web'),
      const GeneratedWord(answer: 'SUCHE', clue: 'Finden'),
      const GeneratedWord(answer: 'ANWENDUNG', clue: 'App'),
      const GeneratedWord(answer: 'ENTWICKLUNG', clue: 'Development'),
    ],
    'it': [
      const GeneratedWord(answer: 'COMPUTER', clue: 'Dispositivo'),
      const GeneratedWord(answer: 'SOFTWARE', clue: 'Programma'),
      const GeneratedWord(answer: 'TASTIERA', clue: 'Input'),
      const GeneratedWord(answer: 'SCHERMO', clue: 'Display'),
      const GeneratedWord(answer: 'INTERNET', clue: 'Rete globale'),
      const GeneratedWord(answer: 'PROGRAMMAZIONE', clue: 'Codifica'),
      const GeneratedWord(answer: 'ALGORITMO', clue: 'Passi'),
      const GeneratedWord(answer: 'DATABASE', clue: 'Archivio'),
      const GeneratedWord(answer: 'SICUREZZA', clue: 'Protezione'),
      const GeneratedWord(answer: 'CODICE', clue: 'Istruzioni'),
      const GeneratedWord(answer: 'ARCHIVIO', clue: 'Documento'),
      const GeneratedWord(answer: 'UTENTE', clue: 'Persona'),
      const GeneratedWord(answer: 'SISTEMA', clue: 'Insieme'),
      const GeneratedWord(answer: 'PROCESSORE', clue: 'CPU'),
      const GeneratedWord(answer: 'MEMORIA', clue: 'RAM'),
      const GeneratedWord(answer: 'ARCHIVIAZIONE', clue: 'Disco'),
      const GeneratedWord(answer: 'BROWSER', clue: 'Web'),
      const GeneratedWord(answer: 'RICERCA', clue: 'Trovare'),
      const GeneratedWord(answer: 'APPLICAZIONE', clue: 'App'),
      const GeneratedWord(answer: 'SVILUPPO', clue: 'Development'),
    ],
    'pt': [
      const GeneratedWord(answer: 'COMPUTADOR', clue: 'Dispositivo'),
      const GeneratedWord(answer: 'SOFTWARE', clue: 'Programa'),
      const GeneratedWord(answer: 'TECLADO', clue: 'Entrada'),
      const GeneratedWord(answer: 'MONITOR', clue: 'Tela'),
      const GeneratedWord(answer: 'INTERNET', clue: 'Rede global'),
      const GeneratedWord(answer: 'PROGRAMACAO', clue: 'Codificacao'),
      const GeneratedWord(answer: 'ALGORITMO', clue: 'Passos'),
      const GeneratedWord(answer: 'DADOS', clue: 'Informacao'),
      const GeneratedWord(answer: 'SEGURANCA', clue: 'Protecao'),
      const GeneratedWord(answer: 'CODIGO', clue: 'Instrucoes'),
      const GeneratedWord(answer: 'ARQUIVO', clue: 'Documento'),
      const GeneratedWord(answer: 'USUARIO', clue: 'Pessoa'),
      const GeneratedWord(answer: 'SISTEMA', clue: 'Conjunto'),
      const GeneratedWord(answer: 'PROCESSADOR', clue: 'CPU'),
      const GeneratedWord(answer: 'MEMORIA', clue: 'RAM'),
      const GeneratedWord(answer: 'ARMAZENAMENTO', clue: 'Disco'),
      const GeneratedWord(answer: 'NAVEGADOR', clue: 'Web'),
      const GeneratedWord(answer: 'PESQUISA', clue: 'Encontrar'),
      const GeneratedWord(answer: 'APLICATIVO', clue: 'App'),
      const GeneratedWord(answer: 'DESENVOLVIMENTO', clue: 'Development'),
    ],
  };

  group('Multi-Language Generation Tests', () {
    for (final lang in ['en', 'fr', 'es', 'de', 'it', 'pt']) {
      test('Generate Technology puzzle in ${lang.toUpperCase()}', () async {
        print('\n${'=' * 70}');
        print('🌍 LANGUAGE TEST: ${lang.toUpperCase()}');
        print('=' * 70);

        final themeWords = languageWords[lang]!;
        print('\n📝 Theme words: ${themeWords.length}');
        print(
          '   Examples: ${themeWords.take(5).map((w) => w.answer).join(", ")}',
        );

        // Load fill dictionary
        final fillService = FillDictionaryService.instance;
        final fillWords = await fillService.loadDictionary(lang);
        print('\n📚 Fill dictionary ($lang): ${fillWords.length} words');

        // Analyze dictionary
        final byLength = <int, int>{};
        for (final word in fillWords) {
          byLength[word.length] = (byLength[word.length] ?? 0) + 1;
        }
        print(
          '   Length 8+: ${byLength.entries.where((e) => e.key >= 8).map((e) => e.value).fold(0, (a, b) => a + b)} words',
        );

        // Run generation
        const attempts = 3;
        final results = <Map<String, dynamic>>[];

        for (var i = 1; i <= attempts; i++) {
          final generator = GridFirstGenerator(
            width: 15,
            height: 15,
            targetBlackRatio: 0.22,
            maxAttempts: 30,
          );

          final result = generator.generate(
            themeWords: themeWords,
            fillWords: fillWords,
          );

          const totalCells = 15 * 15;
          final filledCells =
              result.grid
                  .expand((row) => row)
                  .where((cell) => cell != null)
                  .length;
          final density = filledCells / totalCells;

          results.add({
            'words': result.placedWords.length,
            'density': density,
            'success': result.success,
          });

          print(
            '   Attempt $i: ${result.placedWords.length} words, ${(density * 100).toStringAsFixed(1)}% density',
          );
        }

        // Summary
        final avgWords =
            results.map((r) => r['words'] as int).reduce((a, b) => a + b) /
            attempts;
        final avgDensity =
            results.map((r) => r['density'] as double).reduce((a, b) => a + b) /
            attempts;

        print('\n📊 SUMMARY:');
        print('   Avg words: ${avgWords.toStringAsFixed(1)}');
        print('   Avg density: ${(avgDensity * 100).toStringAsFixed(1)}%');

        expect(avgWords, greaterThan(5), reason: 'Should place 5+ words');
        expect(avgDensity, greaterThan(0.30), reason: 'Density should be 30%+');
      });
    }
  });
}
