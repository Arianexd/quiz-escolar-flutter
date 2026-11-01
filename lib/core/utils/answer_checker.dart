class AnswerChecker {
  static String normalize(String text) {
    const original = 'áàäâéèëêíìïîóòöôúùüûñ';
    const replacement = 'aaaaeeeeiiiioooouuuun';

    var result = text.toLowerCase();

    for (var i = 0; i < original.length; i++) {
      result = result.replaceAll(original[i], replacement[i]);
    }

    return result.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool isCorrect({
    required String userAnswer,
    required String correctAnswer,
    List<String> variants = const [],
  }) {
    final input = normalize(userAnswer);

    if (input.isEmpty) return false;

    final accepted = [correctAnswer, ...variants];

    return accepted.any((answer) => normalize(answer) == input);
  }
}
