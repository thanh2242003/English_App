class WordOrderQuiz {
  final String vietnamese; // nghĩa tiếng Việt
  final List<String> words; // các từ tiếng Anh để sắp xếp
  final List<String> correctOrder; // thứ tự đúng

  WordOrderQuiz({
    required this.vietnamese,
    required this.words,
    required this.correctOrder,
  });
}
