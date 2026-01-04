// ignore_for_file: avoid_print
// This is a CLI tool that intentionally uses print for output.

import 'dart:io';
import 'dart:convert';

void main() async {
  print('--- Fetching Dictionaries for Other Languages ---');

  // Map of language code to URL strategies
  // We use HermitDave's FrequencyWords (Subtitles) as a source
  const baseUrl =
      'https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018';

  final targets = {
    'fr': '$baseUrl/fr/fr_full.txt',
    'es': '$baseUrl/es/es_full.txt',
    'de': '$baseUrl/de/de_full.txt',
    'it': '$baseUrl/it/it_full.txt',
    'pt': '$baseUrl/pt_br/pt_br_full.txt',
    'ru': '$baseUrl/ru/ru_full.txt',
    'uk': '$baseUrl/uk/uk_full.txt',
  };

  final client = HttpClient();

  for (final entry in targets.entries) {
    final lang = entry.key;
    final url = entry.value;
    final outputFile = File('frontend/assets/dictionaries/fill_$lang.txt');

    // Adjust path if running from frontend root
    final effectiveFile = File(
      outputFile.path.startsWith('frontend') &&
              !Directory('frontend').existsSync()
          ? outputFile.path.replaceFirst('frontend/', '')
          : outputFile.path,
    );

    print('\nProcessing $lang from $url...');

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        print(
          'Error: Failed to download $lang (Status ${response.statusCode})',
        );
        continue;
      }

      print('  Downloading...');
      final content = await response.transform(utf8.decoder).join();

      print('  Parsing and Cleaning...');
      final uniqueWords = <String>{};
      final lines = content.split('\n');

      // Regex for valid words (allow accented chars)
      final validWordExp = RegExp(r'^[A-ZÀ-ÖØ-ÞĀ-ŽА-ЯҐЄІЇ]+$');

      for (final line in lines) {
        if (line.trim().isEmpty) {
          continue;
        }

        // Format: "word count"
        final parts = line.trim().split(' ');
        if (parts.isEmpty) {
          continue;
        }

        final word = parts[0].toUpperCase();

        // Skip short words
        if (word.length < 2) {
          continue;
        }

        // Skip words with digits or symbols
        if (word.contains(RegExp(r'[0-9\\._,;:"!¡?¿\(\)\[\]\{\}]'))) {
          continue;
        }

        // Use the regex to validate word characters
        if (validWordExp.hasMatch(word)) {
          uniqueWords.add(word);
        }
      }

      if (uniqueWords.isEmpty) {
        print('  Warning: No valid words found for $lang');
        continue;
      }

      print('  Derived ${uniqueWords.length} unique words.');

      print('  Writing to ${effectiveFile.path}...');
      final sortedList = uniqueWords.toList()..sort();
      final buffer =
          StringBuffer()
            ..writeln('# Auto-fetched dictionary')
            ..writeln('# Source: $url')
            ..writeln('# Date: ${DateTime.now().toIso8601String()}')
            ..writeAll(sortedList, '\n')
            ..writeln();

      await effectiveFile.writeAsString(buffer.toString());
      print(
        '  Success! ${(effectiveFile.lengthSync() / 1024).toStringAsFixed(1)} KB',
      );
    } on Exception catch (e) {
      print('  Error processing $lang: $e');
    }
  }

  client.close();
  print('\nAll done.');
}
