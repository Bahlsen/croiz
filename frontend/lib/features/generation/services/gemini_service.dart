import 'dart:convert';
import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

/// Abstraction for the Gemini model to allow mocking in tests.
// ignore: one_member_abstracts
abstract class GeminiClient {
  Future<String?> generateContent(String prompt);
}

// coverage:ignore-start
/// Production implementation using Firebase AI (Vertex AI).
class FirebaseGeminiClient implements GeminiClient {
  FirebaseGeminiClient(this._model);
  final GenerativeModel _model;

  @override
  Future<String?> generateContent(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text;
  }
}
// coverage:ignore-end

class GeminiPuzzleService {
  GeminiPuzzleService({GeminiClient? client})
    : _client =
          client ??
          // coverage:ignore-start
          FirebaseGeminiClient(
            FirebaseAI.vertexAI().generativeModel(model: _modelName),
          );
  // coverage:ignore-end

  // Default to Flash 2.0 as it's free and fast (1.5 models retired Sept 2025)
  static const _modelName = 'gemini-2.0-flash';
  final GeminiClient _client;

  Future<List<GeneratedWord>> generateWords({
    required String topic,
    required String language, // 'fr', 'en'
    int count = 60, // More words with varied lengths for better grid coverage
    int difficultyLevel = 2, // 1-5
  }) async {
    final prompt = buildPrompt(topic, language, count, difficultyLevel);

    try {
      final text = await _client.generateContent(prompt);

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

      return parseResponse(text);
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

  String buildPrompt(String topic, String lang, int count, int difficulty) =>
      _buildPromptImpl(topic, lang, count, difficulty);

  String _buildPromptImpl(
    String topic,
    String lang,
    int count,
    int difficulty,
  ) {
    // Determine language-specific instructions
    final effectiveLang = lang == 'ru' ? 'uk' : lang;
    final langNames = {
      'en': 'English',
      'fr': 'French',
      'uk': 'Ukrainian',
      'es': 'Spanish',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
    };
    final langName = langNames[effectiveLang] ?? 'English';

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
    if (effectiveLang == 'fr') {
      langConstraints = 'Normalized (remove ALL accents: É->E, Ê->E, Ç->C).';
    } else if (effectiveLang == 'es') {
      langConstraints =
          'Normalized (remove accents like Á, É, Í, Ó, Ú, but PRESERVE the letter Ñ). Only A-Z and Ñ are allowed.';
    } else if (effectiveLang == 'de') {
      langConstraints =
          'Normalized (Convert Umlauts: Ä->AE, Ö->OE, Ü->UE, and ß->SS). Use only A-Z.';
    } else if (effectiveLang == 'uk') {
      langConstraints = 'Use only Ukrainian Cyrillic characters.';
    } else {
      langConstraints = 'Normalized (A-Z only).';
    }

    // Calculate length distribution for better grid coverage
    final shortCount = (count * 0.25).round(); // 25% short (3-4 letters)
    final mediumCount = (count * 0.45).round(); // 45% medium (5-7 letters)
    final longCount =
        count - shortCount - mediumCount; // 30% long (8-15 letters)

    return '''
Generate a list of $count distinct, diverse crossword puzzle words related to the topic: "$topic".
Language: $langName.
Difficulty Level: $difficulty/5.

**CRITICAL: Word Length Distribution** (for optimal crossword grid density):
- $shortCount words of 3-4 letters (short, easy to place, MUST be related to topic)
- $mediumCount words of 5-7 letters (medium length, core thematic vocabulary)
- $longCount words of 8-15 letters (long words, essential for anchoring)

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

  List<GeneratedWord> parseResponse(String text) {
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

  Future<List<GeneratedWord>> generateClues({
    required List<String> words,
    required String language,
    required int difficulty,
  }) async {
    if (words.isEmpty) {
      return [];
    }

    final prompt = _buildCluePrompt(words, language, difficulty);

    try {
      final text = await _client.generateContent(prompt);
      if (text == null) {
        throw UserFriendlyException(
          'Unable to generate clues.',
          technicalDetails: 'Empty response for clue generation',
        );
      }
      return parseResponse(text);
    } on Exception catch (e) {
      developer.log(
        'Gemini clue generation error: $e',
        name: 'GeminiService',
        level: 1000,
      );
      // Fallback: return words with generic clues if API fails
      return words.map((w) => GeneratedWord(answer: w, clue: '...')).toList();
    }
  }

  String _buildCluePrompt(List<String> words, String lang, int difficulty) {
    // Determine language-specific instructions
    final effectiveLang = lang == 'ru' ? 'uk' : lang;
    final langNames = {
      'en': 'English',
      'fr': 'French',
      'uk': 'Ukrainian',
      'es': 'Spanish',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
    };
    final langName = langNames[effectiveLang] ?? 'English';

    return '''
Generate concise crossword clues for the following list of words in $langName.
Difficulty Level: $difficulty/5.

Words:
${words.join(', ')}

Output MUST be a valid JSON array of objects with "word" and "clue" fields.
Format:
[
  {"word": "WORD1", "clue": "Clue for word 1..."},
  {"word": "WORD2", "clue": "Clue for word 2..."}
]
''';
  }
}

// coverage:ignore-start
final geminiPuzzleServiceProvider = Provider<GeminiPuzzleService>(
  (ref) => GeminiPuzzleService(),
);
// coverage:ignore-end
