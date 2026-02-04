import 'dart:convert';
import 'dart:io';

/// V9: Ultra-Professional Crossword Auditor
/// This version implements massive protection for common names, foreign words,
/// and brands. It specifically targets the "Trailing Vowel Split" error (e.g. TRINI -> 4,1).
void main() async {
  final stopwatch = Stopwatch()..start();
  print('Building Knowledge Base...');
  await loadDictionaries();

  final puzzleFiles = await getPuzzleFiles();
  print('Auditing ${puzzleFiles.length} puzzles...');

  int modifiedCount = 0;
  int processedCount = 0;

  for (final file in puzzleFiles) {
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);
      bool modified = false;

      final entries = json['entries'] as List<dynamic>?;
      if (entries == null) continue;

      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) continue;

        final String? answer = entry['answer'];
        final String clueStr = (entry['clue'] ?? '').toString().toLowerCase();

        if (answer == null || answer.isEmpty || answer.length <= 3) {
          if (entry.containsKey('enumeration')) {
            entry.remove('enumeration');
            modified = true;
          }
          continue;
        }

        final segments = segment(answer, clueStr);

        if (segments.length > 1) {
          final enumStr = segments.map((s) => s.length).join(',');
          if (entry['enumeration'] != enumStr) {
            entry['enumeration'] = enumStr;
            modified = true;
          }
        } else {
          if (entry.containsKey('enumeration')) {
            entry.remove('enumeration');
            modified = true;
          }
        }
      }

      if (modified) {
        final encoder = JsonEncoder.withIndent('  ');
        await file.writeAsString(encoder.convert(json));
        modifiedCount++;
      }

      processedCount++;
      if (processedCount % 1000 == 0)
        print('Progress: $processedCount files...');
    } catch (e) {
      // ignore indices
    }
  }

  print(
    'Migration Complete. Modified $modifiedCount files in ${stopwatch.elapsed.inSeconds}s.',
  );
}

// -- DATA --

final Map<String, List<int>> _expertKnowledge = {
  'ONALEASH': [2, 1, 5],
  'ONAROLL': [2, 1, 4],
  'ONATEAR': [2, 1, 4],
  'ONATILT': [2, 1, 4],
  'ONEDGE': [2, 4],
  'INASEC': [2, 1, 3],
  'INAJAM': [2, 1, 3],
  'INAHUFF': [2, 1, 4],
  'INARUT': [2, 1, 3],
  'INAFOG': [2, 1, 3],
  'INADATZ': [2, 1, 4],
  'INTHESWIM': [2, 3, 4],
  'INTHENUDE': [2, 3, 4],
  'COOLBEANS': [4, 5],
  'SEALTEAM': [4, 4],
  'AIRBASE': [3, 4],
  'STANDIN': [5, 2],
  'YOADRIAN': [2, 6],
  'TRYME': [3, 2],
  'DELAYPEDAL': [5, 5],
  'TENHUT': [3, 3],
  'MIXIN': [3, 2],
  'IMOUTIE': [2, 5],
  'OUTOF': [3, 2],
  'STAYAT': [4, 2],
  'HEWHOMUSTNOTBENAMED': [2, 3, 4, 3, 2, 5],
  'NOTBENAMED': [3, 7],
  'HEWHOMUST': [2, 3, 4],
  'NEWYORK': [3, 4],
  'LOSANGELES': [3, 7],
  'SANFRAN': [3, 4],
  'ELONMUSK': [4, 4],
  'BILLGATES': [4, 5],
  'LADYGAGA': [4, 4],
  'COUPDETAT': [4, 2, 4],
  'VISAVIS': [3, 1, 3],
  'HOTDOG': [3, 3],
  'MAKESOUT': [5, 3],
  'STEPONIT': [4, 2, 2],
  'SEETO': [3, 2],
  'IFNOT': [2, 3],
};

final Set<String> _protectedSingleWords = {
  // Common crossword names/brands ending in vowels that look like splits
  'ASAHI',
  'PENSKE',
  'KEEBLER',
  'ESTEE',
  'ELMO',
  'GRETAS',
  'GRETEL',
  'STEVES',
  'ETCH',
  'ALES',
  'AVEC',
  'LIMO',
  'JAKE',
  'EMMA',
  'SAPS',
  'WHITE',
  'BHUTAN',
  'BABAS',
  'CELEB',
  'GIRDS',
  'NISEI',
  'CARETS',
  'ANODE',
  'FICTION',
  'ORBIT',
  'KLINE',
  'NETS',
  'TESTY',
  'ELKS',
  'ELENA',
  'DIANA',
  'TOBE',
  'ALBERT',
  'ROBERT',
  'EDWARD',
  'ALFRED',
  'ALVIN',
  'ALICE',
  'ALAN',
  'ALANA',
  'ALEX',
  'ALEXA',
  'ALEXIS',
  'ALISON',
  'ALINE',
  'ALONDRA',
  'INAS',
  'INET',
  'TRINI',
  'OMNIA',
  'FANTA',
  'SANCTI',
  'COREA',
  'ACCRA',
  'OAHU',
  'LARAM',
  'TRIM',
  'SELL',
  'GRAVY',
  'LENT',
  'NBC',
  'ROSE',
  'DRAW',
  'EMIT',
  'ISADORA',
  'PREMISE',
  'POT',
  'NASH',
  'HOT',
  'NINES',
  'HERB',
  'USED',
  'TIMED',
  'METEORS',
  'ORAN',
  'SAGE',
  'ONCE',
  'ALDO',
  'INRE',
  'INCA',
  'ASKS',
  'ALSO',
  'ALOE',
  'ALOT',
  'AFEW',
  'ABIT',
  'ONLY',
  'EVEN',
  'SOME',
  'MANY',
  'HERE',
  'THERE',
  'WHEN',
  'WHAT',
  'WHOA',
  'WHAM',
  'ALIE',
  'ELIE',
  'ANNE',
  'ANNA',
  'AMIE',
  'AMII',
  'ENOS',
  'EROS',
  'ERAS',
  'ETAS',
  'ETES',
  'LEES',
  'ALAS',
  'ARIA',
  'AREA',
  'ORAL',
  'IDOL',
  'IDEA',
  'IRON',
  'IRIS',
  'ICON',
  'ITEM',
  'INCH',
  'INTO',
  'IOTA',
  'INANE',
  'INPUT',
  'INNER',
  'INDEX',
  'INDIA',
  'INERT',
  'INFER',
  'INFRA',
  'INGOT',
  'INLAY',
  'INLET',
  'INSET',
  'INTER',
  'INTRA',
  'INURE',
  'INVOX',
  'ASSET',
  'ASIAN',
  'ASIDE',
  'ASPIE',
  'ASSAY',
  'ASTER',
  'ASTIR',
  'ASTRO',
  'ASYLUM',
  'ASLEEP',
  'ASSERT',
  'ASSIGN',
  'ASSIST',
  'ASSORT',
  'ASSUME',
  'ASSURE',
  'ASTERN',
  'ASTUTE',
  'ASTRAY',
  'ASUNDER',
};

final Set<String> _commonWords = {
  'THE',
  'BE',
  'TO',
  'OF',
  'AND',
  'A',
  'IN',
  'THAT',
  'HAVE',
  'I',
  'IT',
  'FOR',
  'NOT',
  'ON',
  'WITH',
  'HE',
  'AS',
  'YOU',
  'DO',
  'AT',
  'THIS',
  'BUT',
  'HIS',
  'BY',
  'FROM',
  'THEY',
  'WE',
  'SAY',
  'HER',
  'SHE',
  'OR',
  'AN',
  'WILL',
  'MY',
  'ONE',
  'ALL',
  'WOULD',
  'THERE',
  'WHAT',
  'SO',
  'UP',
  'OUT',
  'IF',
  'ABOUT',
  'WHO',
  'GET',
  'WHICH',
  'GO',
  'ME',
  'WHEN',
  'MAKE',
  'CAN',
  'LIKE',
  'TIME',
  'NO',
  'JUST',
  'HIM',
  'KNOW',
  'TAKE',
  'INTO',
  'YEAR',
  'YOUR',
  'GOOD',
  'SOME',
  'COULD',
  'THEM',
  'SEE',
  'OTHER',
  'THAN',
  'THEN',
  'NOW',
  'LOOK',
  'ONLY',
  'COME',
  'ITS',
  'OVER',
  'THINK',
  'ALSO',
  'BACK',
  'AFTER',
  'USE',
  'TWO',
  'HOW',
  'OUR',
  'WORK',
  'FIRST',
  'WELL',
  'WAY',
  'EVEN',
  'NEW',
  'WANT',
  'ANY',
  'THESE',
  'GIVE',
  'DAY',
  'MOST',
  'US',
  'ETA',
  'ELI',
  'ALI',
  'ERA',
  'ALE',
  'LEE',
  'ANA',
  'AMA',
};

final Set<String> _megaDict = {};

Future<void> loadDictionaries() async {
  final file = File('assets/dictionaries/words_alpha.txt');
  if (await file.exists()) {
    final lines = await file.readAsLines();
    _megaDict.addAll(lines.map((l) => l.trim().toUpperCase()));
  }
}

Future<List<File>> getPuzzleFiles() async {
  final dir = Directory('assets/data');
  return dir
      .list(recursive: true)
      .where(
        (f) =>
            f is File &&
            f.path.endsWith('.json') &&
            !f.path.contains('puzzles.json'),
      )
      .cast<File>()
      .toList();
}

List<String> segment(String input, String clue) {
  if (input.isEmpty) return [];

  // Semantic clue categories
  bool isPhraseClue =
      clue.contains('phrase') ||
      clue.contains('saying') ||
      clue.contains('being ') ||
      clue.startsWith('with ') ||
      clue.startsWith('to ') ||
      clue.startsWith('a ') ||
      clue.startsWith('an ') ||
      clue.startsWith('the ') ||
      clue.contains(', say') ||
      clue.contains('expression') ||
      clue.contains('words') ||
      clue.contains('\"') ||
      clue.startsWith('\"') ||
      clue.endsWith('\"') ||
      clue.contains('!\"') ||
      clue.contains('... or');

  bool isProperEntityClue =
      clue.contains('actor') ||
      clue.contains('actress') ||
      clue.contains('director') ||
      clue.contains('coach') ||
      clue.contains('player') ||
      clue.contains('singer') ||
      clue.contains('author') ||
      clue.contains('writer') ||
      clue.contains('statesman') ||
      clue.contains('senator') ||
      clue.contains('brand') ||
      clue.contains('port') ||
      clue.contains('city') ||
      clue.contains('river') ||
      clue.contains('island') ||
      clue.contains('capital') ||
      clue.contains('activist') ||
      clue.contains('name') ||
      clue.contains('surname') ||
      clue.contains('role') ||
      clue.contains('starred') ||
      clue.contains('composer') ||
      clue.contains('lat.') ||
      clue.contains('span.') ||
      clue.contains('latin');

  // Hardcoded known protection
  if (_protectedSingleWords.contains(input)) {
    // Explicitly allow multi-word if clue IS a phrase clue and NOT a proper entity
    if (input == 'TOBE' && isPhraseClue && !isProperEntityClue)
      return ['TO', 'BE'];
    if (input == 'ABIT' && isPhraseClue) return ['A', 'BIT'];
    if (input == 'ALOT' && isPhraseClue) return ['A', 'LOT'];
    if (input == 'AFEW' && isPhraseClue) return ['A', 'FEW'];
    if (input == 'DOIT' && isPhraseClue) return ['DO', 'IT'];
    return [input];
  }

  if (_expertKnowledge.containsKey(input)) {
    int start = 0;
    final List<String> segs = [];
    for (int len in _expertKnowledge[input]!) {
      segs.add(input.substring(start, start + len));
      start += len;
    }
    return segs;
  }

  // Length 4 words are EXTREMELY safe to protect
  if (input.length <= 4) {
    if (!isPhraseClue || isProperEntityClue) return [input];
  }

  // If the word ends in a single letter like A or I, be VERY skeptical
  // "OMNIA" -> "OMNI" + "A". "TRINI" -> "TRIN" + "I". "FANTA" -> "FANT" + "A".
  // Only allow this if it's a known phrase.
  if (input.endsWith('A') ||
      input.endsWith('I') ||
      input.endsWith('O') ||
      input.endsWith('E')) {
    if (!isPhraseClue && !input.startsWith('A') && !input.startsWith('I')) {
      // e.g. "FANTA" (Ends in A, doesn't start with A/I). Protect.
      return [input];
    }
  }

  // If in Dict and not a blatant phrase clue, assume 1 word
  if (input.length >= 4 && _megaDict.contains(input)) {
    if (!isPhraseClue) return [input];
  }

  final n = input.length;
  final minWords = List<int>.filled(n + 1, 100);
  final parent = List<int>.filled(n + 1, -1);
  minWords[0] = 0;

  for (int i = 1; i <= n; i++) {
    for (int j = 0; j < i; j++) {
      final word = input.substring(j, i);
      bool isValid = false;
      if (_commonWords.contains(word)) {
        isValid = true;
      } else if (word.length >= 4 && _megaDict.contains(word)) {
        isValid = true;
      } else if (word == 'I' || word == 'A') {
        isValid = true;
      }
      if (isValid) {
        if (minWords[j] + 1 < minWords[i]) {
          minWords[i] = minWords[j] + 1;
          parent[i] = j;
        }
      }
    }
  }

  if (minWords[n] > 10) return [input];

  final List<String> res = [];
  int curr = n;
  while (curr > 0) {
    final prev = parent[curr];
    res.add(input.substring(prev, curr));
    curr = prev;
  }
  final segments = res.reversed.toList();

  if (segments.length > 1) {
    if (isProperEntityClue) return [input];

    // Check for trailing letter split (e.g. 4,1 or 5,1)
    if (segments.last.length == 1 &&
        segments.last != 'A' &&
        segments.last != 'I')
      return [input];
    if (segments.last.length == 1 && !isPhraseClue) return [input];

    bool allCommon = segments.every(
      (s) => _commonWords.contains(s) || s == 'A' || s == 'I',
    );
    if (!isPhraseClue && !allCommon) return [input];
  }

  for (var s in segments)
    if (s.length == 1 && s != 'A' && s != 'I') return [input];

  return segments;
}
