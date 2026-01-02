import 'dart:convert';
import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

class GeminiPuzzleService {
  GeminiPuzzleService({GenerativeModel? model})
    : _model =
          model ?? FirebaseAI.vertexAI().generativeModel(model: _modelName);

  // Default to Flash 2.0 as it's free and fast (1.5 models retired Sept 2025)
  static const _modelName = 'gemini-2.0-flash';
  final GenerativeModel _model;

  Future<List<GeneratedWord>> generateWords({
    required String topic,
    required String language, // 'fr', 'en'
    int count = 25,
    int difficultyLevel = 2, // 1-5
  }) async {
    // FirebaseAI automatically uses the Firebase app credentials
    final prompt = _buildPrompt(topic, language, count, difficultyLevel);

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null) {
        developer.log(
          'Empty response from Gemini API',
          name: 'GeminiService',
          level: 900,
        );
        throw UserFriendlyException(
          'Unable to generate puzzle. Please try again.',
          technicalDetails: 'Empty response from Gemini API',
        );
      }

      return _parseResponse(text);
    } on UserFriendlyException {
      // Re-throw user-friendly exceptions as-is
      rethrow;
    } catch (e) {
      developer.log(
        'Gemini generation error: $e',
        name: 'GeminiService',
        level: 1000,
      );

      // Convert technical errors to user-friendly messages
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('firebase') ||
          errorMessage.contains('api') ||
          errorMessage.contains('permission') ||
          errorMessage.contains('disabled')) {
        throw UserFriendlyException(
          'Service temporarily unavailable. Please try again later.',
          technicalDetails: e.toString(),
        );
      }

      throw UserFriendlyException(
        'Unable to generate puzzle. Please try again.',
        technicalDetails: e.toString(),
      );
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

    // Detailed difficulty criteria
    String diffInstructions;
    switch (difficulty) {
      case 1: // Very Easy
        diffInstructions = '''
- Target Audience: Beginners and kids.
- Words: Very common, everyday words. Avoid any obscure terms.
- Clues: Direct, literal definitions. Simple and short.
- Topic Connection: Use general knowledge related to "$topic".
''';
        break;
      case 2: // Easy
        diffInstructions = '''
- Target Audience: Casual solvers.
- Words: Mostly common words.
- Clues: Straightforward definitions.
- Topic Connection: Standard facts about "$topic".
''';
        break;
      case 3: // Medium
        diffInstructions = '''
- Target Audience: Regular crossword players.
- Words: Mix of common and some slightly less common words.
- Clues: Standard definitions, occasional synonyms or simple associations.
- Topic Connection: Good knowledge of "$topic".
''';
        break;
      case 4: // Hard
        diffInstructions = '''
- Target Audience: Experienced solvers.
- Words: Include some rare, literary, or technical terms.
- Clues: Use synonyms, associations, or slightly abstract descriptions.
- Topic Connection: Specific or detailed knowledge of "$topic".
''';
        break;
      case 5: // Expert
        diffInstructions = '''
- Target Audience: Experts.
- Words: Rare, obscure, or specific vocabulary. Long words preferred.
- Clues: Puns, wordplay, double meanings, cryptic hints, or abstract associations.
- Topic Connection: Deep cuts, obscure facts, or tangential relationships to "$topic".
''';
        break;
      default:
        diffInstructions = 'Standard difficulty.';
    }

    // Language-specific normalization and character constraints
    String langConstraints;
    if (lang == 'fr') {
      langConstraints = 'Normalized (remove ALL accents: É->E, Ê->E, Ç->C).';
    } else if (lang == 'es') {
      langConstraints =
          'Normalized (remove accents like Á, É, Í, Ó, Ú, but PRESERVE the letter Ñ). Only A-Z and Ñ are allowed.';
    } else if (lang == 'de') {
      langConstraints =
          'Normalized (Convert Umlauts: Ä->AE, Ö->OE, Ü->UE, and ß->SS). Use only A-Z.';
    } else {
      langConstraints = 'Normalized (A-Z only).';
    }

    return '''
Generate a list of $count distinct crossword puzzle words related to the topic: "$topic".
Language: $langName.
Difficulty Level: $difficulty/5.

Specific Difficulty Instructions:
$diffInstructions

Global Constraints:
1. Valid $langName dictionary word.
2. Between 3 and 15 letters long.
3. No spaces, no hyphens.
4. $langConstraints
5. Provide a clue for each word based on the difficulty instructions above.

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
      developer.log(
        'Failed to parse JSON from AI: $cleaner. Error: $e',
        name: 'GeminiService',
        level: 1000,
      );
      throw UserFriendlyException(
        'An error occurred during generation. Please try again.',
        technicalDetails: 'Failed to parse JSON from AI: $e',
      );
    }
  }
}

final geminiPuzzleServiceProvider = Provider<GeminiPuzzleService>(
  (ref) => GeminiPuzzleService(),
);
