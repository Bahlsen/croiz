class GeneratedWord {
  const GeneratedWord({required this.answer, required this.clue});

  factory GeneratedWord.fromJson(Map<String, dynamic> json) => GeneratedWord(
    answer: (json['word'] ?? json['answer'] ?? '')
        .toString()
        .toUpperCase()
        .trim(),
    clue: (json['clue'] ?? '').toString().trim(),
  );

  final String answer;
  final String clue;
}
