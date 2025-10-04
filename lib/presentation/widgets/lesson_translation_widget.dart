import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/models/translation_quiz.dart';

class LessonTranslationWidget extends StatefulWidget {
  const LessonTranslationWidget({
    super.key,
    required this.question,
    required this.onNext,
  });

  final TranslationQuiz question;
  final VoidCallback onNext; // callback khi nhấn "Tiếp theo"

  @override
  State<LessonTranslationWidget> createState() =>
      _LessonTranslationWidgetState();
}

class _LessonTranslationWidgetState extends State<LessonTranslationWidget> {
  String? selectedOption;
  bool? isCorrect;
  bool showResult = false;

  void _handleSelect(String option) {
    setState(() {
      selectedOption = option;
      isCorrect = option == widget.question.meaning;
      showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Nội dung chính
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // English word
                Container(
                  margin: const EdgeInsets.only(left: 70),
                  child: Text(
                    widget.question.englishWord,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10),
                // Image
                Center(
                  child: Image.asset(
                    widget.question.imagePath,
                    width: 360,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 120),
                // Options
                if (!showResult)
                  ...widget.question.options.map(
                        (option) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: MyButton(
                        data: option,
                        onTap: () => _handleSelect(option),
                      ),
                    ),
                  ),
              ],
            ),

            // Popup kết quả
            if (showResult) _buildResultBox(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(BuildContext context) {
    final color = isCorrect! ? Colors.green : Colors.red;
    final message = isCorrect! ? "🎉 Chính xác!" : "❌ Sai rồi!";
    final correctAnswer =
        "${widget.question.englishWord} - ${widget.question.meaning}";

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  correctAnswer,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          //const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              //minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              setState(() {
                showResult = false;
                selectedOption = null;
                isCorrect = null;
              });
              widget.onNext(); // gọi callback để chuyển câu tiếp theo
            },
            child: const Text(
              "Tiếp theo",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
}
