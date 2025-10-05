// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:english_app/models/match_word_quiz.dart';
// import 'package:english_app/models/typing_quiz.dart';
// import 'package:english_app/presentation/widgets/lesson_match_widget.dart';
// import 'package:english_app/presentation/widgets/lesson_typing_widget.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:english_app/data/exercise_data.dart';
// import 'package:english_app/models/exercise_step.dart';
// import 'package:english_app/models/translation_quiz.dart';
// import 'package:english_app/presentation/widgets/lesson_translation_widget.dart';
//
// import '../../models/word_order_quiz.dart';
// import '../widgets/word_order_widget.dart';
// import 'home_screen.dart';
//
// class ExerciseScreen extends StatefulWidget {
//   const ExerciseScreen({super.key});
//
//   @override
//   State<ExerciseScreen> createState() => _ExerciseScreenState();
// }
//
// class _ExerciseScreenState extends State<ExerciseScreen> {
//   int currentStep = 0;
//
//   //lưu tiến độ vào firebase
//   Future<bool> saveProgress({
//     required String lessonId,
//     required int stepIndex,
//   }) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print("saveProgress: no logged in user");
//       return false;
//     }
//
//     final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//
//     try {
//       await docRef.set({
//         'progress': {
//           'currentLesson': lessonId,
//           'currentStep': stepIndex,
//           'lastCompletedAt': FieldValue.serverTimestamp(),
//         },
//       }, SetOptions(merge: true));
//
//       print('saveProgress: saved for ${user.uid}');
//       return true;
//     } catch (e, st) {
//       print('saveProgress ERROR: $e\n$st');
//       return false;
//     }
//   }
//
//   //điều hướng sang câu tiếp theo
//   void _goToNextStep() async {
//     if (currentStep < step.length - 1) {
//       setState(() {
//         currentStep++;
//       });
//     } else {
//       await saveProgress(lessonId: 'lesson_1', stepIndex: step.length);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("🎉 Hoàn thành bài học!")));
//       await Future.delayed(const Duration(seconds: 1));
//
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final exercise = step[currentStep];
//     final String instruction = exercise.instruction;
//     Widget content;
//
//     switch (exercise.type) {
//       case ExerciseType.matchWords:
//         final data = exercise.data as MatchWordsQuiz;
//         content = LessonMatchWidget(data: data, onNext: _goToNextStep);
//         break;
//       case ExerciseType.chooseTranslation:
//         final data = exercise.data as TranslationQuiz;
//         content = LessonTranslationWidget(
//           question: data,
//           onNext: _goToNextStep,
//         );
//         break;
//       case ExerciseType.typingQuiz:
//         final data = exercise.data as TypingQuiz;
//         content = LessonTypingWidget(
//           question: data.vietnamese,
//           answer: data.english,
//           onNext: _goToNextStep, // callback chuyển sang câu tiếp theo
//         );
//         break;
//       case ExerciseType.wordOrder:
//         final data = step.data as WordOrderQuiz;
//         return WordOrderWidget(
//           quiz: data,
//           onCorrect: _goToNextStep,
//         );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Thanh tiến trình
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               child: LinearProgressIndicator(
//                 value: (currentStep + 1) / step.length,
//                 backgroundColor: const Color(0xFF3A3939),
//                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
//                 minHeight: 15,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             // instruction text
//             Text(
//               instruction,
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 20),
//             //Nội dung
//             Expanded(child: content),
//           ],
//         ),
//       ),
//     );
//   }
// }
