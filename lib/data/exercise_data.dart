import 'package:english_app/models/match_word_quiz.dart';

import '../models/exercise_step.dart';
import '../models/translation_quiz.dart';
import '../models/typing_quiz.dart';
import '../models/word_order_quiz.dart';

final lesson1 = Lesson(
  title: "Bài 1: Các từ cơ bản",
  parts: [
    Part(
      title: "Phần 1",
      exercises: [
        ExerciseStep(
          type: ExerciseType.matchWords,
          instruction: 'Ghép từ tương ứng',
          data: MatchWordsQuiz(
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
            englishWord: "Like",
            options: ["Thích", "Mở"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.chooseTranslation,
          instruction: 'Chọn bản dịch',
          data: TranslationQuiz(
            imagePath: "assets/images/want_word.jpg",
            meaning: "Muốn",
            englishWord: "Want",
            options: ["Muốn", "Ngủ"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.chooseTranslation,
          instruction: 'Chọn bản dịch',
          data: TranslationQuiz(
            imagePath: "assets/images/work_word.jpg",
            meaning: "Làm việc",
            englishWord: "Work",
            options: ["Làm việc", "Uống"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.chooseTranslation,
          instruction: 'Chọn bản dịch',
          data: TranslationQuiz(
            imagePath: "assets/images/tea_word.jpg",
            meaning: "Trà",
            englishWord: "Tea",
            options: ["Trà", "Nước"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.chooseTranslation,
          instruction: 'Chọn bản dịch',
          data: TranslationQuiz(
            imagePath: "assets/images/coffee_word.jpg",
            meaning: "Cà phê",
            englishWord: "Coffee",
            options: ["Cà phê", "Sữa"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.chooseTranslation,
          instruction: 'Chọn bản dịch',
          data: TranslationQuiz(
            imagePath: "assets/images/here_word.jpg",
            meaning: "Đây, ở đây",
            englishWord: "Here",
            options: ["Đây, ở đây", "Bản đồ"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.typingQuiz,
          instruction: 'Nhập vào bản dịch',
          data: TypingQuiz(vietnamese: 'thích', english: 'like'),
        ),
        ExerciseStep(
          type: ExerciseType.typingQuiz,
          instruction: 'Nhập vào bản dịch',
          data: TypingQuiz(vietnamese: 'muốn', english: 'want'),
        ),
        ExerciseStep(
          type: ExerciseType.typingQuiz,
          instruction: 'Nhập vào bản dịch',
          data: TypingQuiz(vietnamese: 'làm việc', english: 'work'),
        ),
        ExerciseStep(
          type: ExerciseType.typingQuiz,
          instruction: 'Nhập vào bản dịch',
          data: TypingQuiz(vietnamese: 'trà', english: 'tea'),
        ),
        ExerciseStep(
          type: ExerciseType.typingQuiz,
          instruction: 'Nhập vào bản dịch',
          data: TypingQuiz(vietnamese: 'cà phê', english: 'coffee'),
        ),
        ExerciseStep(
          type: ExerciseType.typingQuiz,
          instruction: 'Nhập vào bản dịch',
          data: TypingQuiz(vietnamese: 'ở đây', english: 'here'),
        ),
      ],
    ),
    //Part 2
    Part(
      title: "Phần 2",
      exercises: [
        ExerciseStep(
          type: ExerciseType.wordOrder,
          instruction: "Sắp xếp các từ thành câu đúng",
          data: WordOrderQuiz(
            vietnamese: "Tôi thích trà",
            words: ["tea", "I", "like"], // xáo trộn nếu muốn
            correctOrder: ["I", "like", "tea"],
          ),
        ),
        ExerciseStep(
          type: ExerciseType.wordOrder,
          instruction: "Sắp xếp các từ tiếng Anh thành câu đúng",
          data: WordOrderQuiz(
            vietnamese: "Bạn muốn cà phê",
            words: ["coffee", "You", "want"],
            correctOrder: ["You", "want", "coffee"],
          ),
        ),
      ],
    ),
  ],
);
