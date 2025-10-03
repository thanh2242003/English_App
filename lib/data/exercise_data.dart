import 'package:english_app/data/match_words_data.dart';
import 'package:english_app/models/exercise_step.dart';

import '../models/translation_quiz.dart';

List<ExerciseStep> step = [
  ExerciseStep(
    type: ExerciseType.matchWords,
    instruction: 'Ghép từ tương ứng',
    data: MatchWordsData(
      wordMap: {
        "Like": "Thích",
        "Want": "Muốn",
        "Work": "Làm việc",
        "Tea": "Trà",
        "Coffee": "Cà phê",
        "Here": "Ở đây",
      },
    ),
  ),
  ExerciseStep(
    type: ExerciseType.chooseTranslation,
    instruction: 'Chọn bản dịch',
    data: TranslationQuiz(
      imagePath: "assets/images/like_word.jpg",
      meaning: "Thích",
      correctWord: "Like",
      options: ["Like", "Open"],
    ),
  ),
  ExerciseStep(
    type: ExerciseType.chooseTranslation,
    instruction: 'Chọn bản dịch',
    data: TranslationQuiz(
      imagePath: "assets/images/want_word.jpg",
      meaning: "Muốn",
      correctWord: "Want",
      options: ["Want", "Sleep"],
    ),
  ),
  ExerciseStep(
    type: ExerciseType.chooseTranslation,
    instruction: 'Chọn bản dịch',
    data: TranslationQuiz(
      imagePath: "assets/images/work_word.jpg",
      meaning: "Làm việc",
      correctWord: "Work",
      options: ["Work", "Drink"],
    ),
  ),
  ExerciseStep(
    type: ExerciseType.chooseTranslation,
    instruction: 'Chọn bản dịch',
    data: TranslationQuiz(
      imagePath: "assets/images/tea_word.jpg",
      meaning: "Trà",
      correctWord: "Tea",
      options: ["Tea", "Water"],
    ),
  ),
  ExerciseStep(
    type: ExerciseType.chooseTranslation,
    instruction: 'Chọn bản dịch',
    data: TranslationQuiz(
      imagePath: "assets/images/coffee_word.jpg",
      meaning: "Cà phê",
      correctWord: "Coffee",
      options: ["Coffee", "Milk"],
    ),
  ),
  ExerciseStep(
    type: ExerciseType.chooseTranslation,
    instruction: 'Chọn bản dịch',
    data: TranslationQuiz(
      imagePath: "assets/images/here_word.jpg",
      meaning: "Đây, ở đây",
      correctWord: "Here",
      options: ["Here", "Near"],
    ),
  ),
];
