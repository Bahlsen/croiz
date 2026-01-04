import 'dart:convert';
import 'dart:io';

void main() {
  // Assuming script is run from project root (c:\Projects\croiz) or frontend root
  // We'll try to find the assets directory relative to current location
  Directory dataDir;
  File targetFile;

  if (Directory('frontend/assets/data').existsSync()) {
    // We are in project root
    dataDir = Directory('frontend/assets/data');
    targetFile = File('frontend/assets/dictionaries/fill_en.txt');
  } else if (Directory('assets/data').existsSync()) {
    // We are in frontend root
    dataDir = Directory('assets/data');
    targetFile = File('assets/dictionaries/fill_en.txt');
  } else {
    print('Error: Could not find assets/data directory.');
    print('Current directory: ${Directory.current.path}');
    exit(1);
  }

  print('Scanning ${dataDir.path} for puzzles...');
  print('Target dictionary: ${targetFile.path}');

  // Set to store unique words
  final uniqueWords = <String>{};
  int processedFiles = 0;
  int errorFiles = 0;

  // Walk the directory
  try {
    final entities = dataDir.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        // Skip index files
        if (entity.path.contains('puzzles_index') ||
            entity.path.contains('puzzles.json')) {
          continue;
        }

        try {
          final content = entity.readAsStringSync();
          final json = jsonDecode(content);

          // Format 1: 'clues' -> 'across'/'down' -> 'answer' (NYT, Atlantic)
          if (json is Map) {
            if (json.containsKey('clues')) {
              final clues = json['clues'];
              if (clues is Map) {
                _extractFromClues(clues['across'], uniqueWords);
                _extractFromClues(clues['down'], uniqueWords);
              }
            }
          }

          processedFiles++;
          if (processedFiles % 500 == 0) {
            stdout.write(
              '\rProcessed $processedFiles puzzles. Unique words found: ${uniqueWords.length}',
            );
          }
        } catch (e) {
          errorFiles++;
          // Silently ignore parse errors
        }
      }
    }
  } catch (e) {
    print('Error listing directory: $e');
    exit(1);
  }

  print('\n\n--- Extraction Complete ---');
  print('Total puzzles processed: $processedFiles');
  print('Errors/Skipped: $errorFiles');
  print('Total unique words found: ${uniqueWords.length}');

  if (uniqueWords.isEmpty) {
    print('Warning: No words found. Dictionary will not be updated.');
    exit(1);
  }

  // Sort and write
  print('Sorting and writing to file...');
  final sortedWords = uniqueWords.toList()..sort();
  final buffer = StringBuffer();

  // Add some header comments
  buffer.writeln('# Auto-generated dictionary from local puzzle database');
  buffer.writeln('# Source: assets/data');
  buffer.writeln('# Count: ${uniqueWords.length} words');
  buffer.writeln('# Date: ${DateTime.now().toIso8601String()}');

  for (final word in sortedWords) {
    // Filter:
    // 1. Length >= 2
    // 2. Only letters (sanity check, though sanitization happened earlier)
    if (word.length >= 2) {
      buffer.writeln(word);
    }
  }

  targetFile.writeAsStringSync(buffer.toString());
  print('Success! Dictionary saved to ${targetFile.path}');
  print('File size: ${(targetFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
}

void _extractFromClues(dynamic list, Set<String> target) {
  if (list is List) {
    for (final item in list) {
      if (item is Map && item['answer'] is String) {
        final answer = item['answer'] as String;
        // Sanitize: only ASCII letters A-Z
        // Remove spaces, hyphens, numbers, etc.
        final clean = answer.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');

        // Only add if it looks like a valid word
        if (clean.isNotEmpty) {
          target.add(clean);
        }
      }
    }
  }
}
