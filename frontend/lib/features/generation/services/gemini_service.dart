import 'dart:convert';
import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

class GeminiPuzzleService {
  GeminiPuzzleService();

  // Default to Flash as it's free and fast
  static const _modelName = 'gemini-1.5-flash';

  Future<List<GeneratedWord>> generateWords({
    required String topic,
    required String language, // 'fr', 'en'
    int count = 25,
    int difficultyLevel = 2, // 1-5
  }) async {
    // FirebaseAI automatically uses the Firebase app credentials
    final model = FirebaseAI.vertexAI().generativeModel(model: _modelName);
    final prompt = _buildPrompt(topic, language, count, difficultyLevel);

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null) {
        throw Exception('Empty response from Gemini');
      }

      return _parseResponse(text);
    } catch (e) {
      developer.log('Gemini generation error: $e', name: 'GeminiService');
      rethrow;
    }
  }

  String _buildPrompt(String topic, String lang, int count, int difficulty) {
    // Determine language-specific instructions
    final langName = lang == 'fr' ? 'French' : 'English';
    const jsonFormat = '''
[
  {"word": "EXAMPLE", "clue": "Description..."},
  ...
]
''';

    // Difficulty nuance
    String diffDesc;
    if (difficulty <= 2) {
      diffDesc = 'simple and common words';
    } else if (difficulty >= 4) {
      diffDesc = 'complex, rare or scholarly words';
    } else {
      diffDesc = 'medium difficulty words';
    }

    return '''
Generate a list of $count distinct crossword puzzle words related to the topic: "$topic".
Language: $langName.
Difficulty: $diffDesc.

Each word must be:
1. Valid $langName dictionary word.
2. Between 3 and 15 letters long.
3. No spaces, no hyphens, just A-Z letters.
4. Normalized (remove accents: É->E, Ê->E).

5. Provide a clue for each word. The clue should be definition-style (crossword style).

Output MUST be a valid JSON array. Do not include markdown formatting like ```json ... ```. 
Just the raw JSON array.

Format:
$jsonFormat
''';
  }

  List<GeneratedWord> _parseResponse(String text) {
    // Sanitize: sometimes models output markdown blocks
    var cleaner = text.trim();
    if (cleaner.startsWith('```json')) {
      cleaner = cleaner.replaceAll('```json', '').replaceAll('```', '');
    } else if (cleaner.startsWith('```')) {
      cleaner = cleaner.replaceAll('```', '');
    }

    try {
      final List<dynamic> jsonList = jsonDecode(cleaner);
      return jsonList
          .map((e) => GeneratedWord.fromJson(e as Map<String, dynamic>))
          .where((w) => w.answer.length >= 2) // Filter out garbage
          .toList();
    } catch (e) {
      throw Exception('Failed to parse JSON from AI: $cleaner. Error: $e');
    }
  }
}

// Simplified provider - no more API key needed!
final geminiPuzzleServiceProvider = Provider<GeminiPuzzleService>(
  (ref) => GeminiPuzzleService(),
);
