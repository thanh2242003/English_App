import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:english_app/presentation/widgets/result_popup_widget.dart';

class LessonTranslationWidget extends StatefulWidget {
  const LessonTranslationWidget({
    super.key,
    required this.question,
    required this.onNext,
  });

  final TranslationQuiz question;
  final VoidCallback onNext;

  @override
  State<LessonTranslationWidget> createState() =>
      _LessonTranslationWidgetState();
}

class _LessonTranslationWidgetState extends State<LessonTranslationWidget> {
  String? selectedOption;
  bool? isCorrect;
  bool showResult = false;
  
  // Text-to-speech
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    // Phát âm từ tiếng anh khi vừa vào màn hình
    Future.delayed(const Duration(milliseconds: 200), () {
      _speak(widget.question.englishWord);
    });
  }
  
  @override
  void didUpdateWidget(LessonTranslationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Phát âm từ tiếng anh mới chuyển sang từ mới
    if (oldWidget.question.englishWord != widget.question.englishWord) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _speak(widget.question.englishWord);
      });
    }
  }
  
  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }
  
  void _speak(String text) async {
    await flutterTts.speak(text);
  }
  
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

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
                  margin: const EdgeInsets.only(left: 20),
                  child: GestureDetector(
                    onTap: () => _speak(widget.question.englishWord),
                    child: Text(
                      widget.question.englishWord,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
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
                        horizontal: 20,
                        vertical: 10,
                      ),
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
    final correctAnswer = "${widget.question.englishWord} - ${widget.question.meaning}";
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ResultPopupWidget(
          message: isCorrect! ? "Chính xác!" : "Chưa chính xác",
          correctAnswer: correctAnswer,
          backgroundColor: isCorrect! ? Colors.green : Colors.red,
          englishText: widget.question.englishWord,
          onNext: () {
            setState(() {
              showResult = false;
              selectedOption = null;
              isCorrect = null;
            });
            widget.onNext();
          },
        ),
        SizedBox(height: 100,),
      ],
    );
  }
}
