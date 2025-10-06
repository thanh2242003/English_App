import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:english_app/presentation/widgets/result_popup_widget.dart';
import 'custom_keyboard.dart';

class LessonTypingWidget extends StatefulWidget {
  const LessonTypingWidget({
    super.key,
    required this.question,
    required this.answer,
    this.onNext,
  });

  final String question; // ví dụ: "Cà phê"
  final String answer; // ví dụ: "coffee"
  final VoidCallback? onNext; // callback khi bấm "Tiếp theo"

  @override
  State<LessonTypingWidget> createState() => _LessonTypingWidgetState();
}

class _LessonTypingWidgetState extends State<LessonTypingWidget> {
  late List<String> answerChars;
  String userInput = "";
  bool showResult = false;
  bool isCorrect = false;
  
  // Text-to-speech
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }
  
  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.9);
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

  // Khi nhấn chữ cái
  void _onKeyPress(String char) {
    if (showResult) return;
    if (userInput.length < widget.answer.toLowerCase().trim().length) {
      setState(() {
        userInput += char;
      });
    }
  }

  // Khi nhấn nút xóa
  void _onDelete() {
    if (showResult) return;
    if (userInput.isNotEmpty) {
      setState(() {
        userInput = userInput.substring(0, userInput.length - 1);
      });
    }
  }

  // Khi nhấn kiểm tra
  void _onCheck() {
    if (userInput.length != widget.answer.toLowerCase().trim().length) return;
    setState(() {
      isCorrect = userInput.toLowerCase() == widget.answer.toLowerCase();
      showResult = true;
    });

    // Nếu đúng thì phát âm từ tiếng Anh
    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _speak(widget.answer);
      });
    } else {
      //sai thì popup sai
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          showResult = false;
          userInput = ''; // Xóa input để người dùng nhập lại
        });
      });
    }
  }

  // Hiển thị popup kết quả
  Widget _buildResultBox(BuildContext context) {
    final correctAnswer = "${widget.answer} - ${widget.question}";
    
    if (isCorrect) {
      return ResultPopupWidget(
        message: "Chính xác!",
        correctAnswer: correctAnswer,
        englishText: widget.answer,
        onNext: () {
          setState(() {
            showResult = false;
            userInput = '';
            isCorrect = false;
          });
          widget.onNext?.call(); // Chuyển sang câu tiếp theo
        },
      );
    } else {
      // Khi sai, chỉ hiển thị text đơn giản
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "Chưa chính xác!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final answerChars = widget.answer.toLowerCase().trim().split('');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Nhập bản dịch cho:",
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
                Text(
                  widget.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Hiển thị các ký tự nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(answerChars.length, (index) {
                    final char = (index < userInput.length)
                        ? userInput[index].toUpperCase()
                        : "_";
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        char,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // Gọi bàn phím custom
                Column(
                  children: [
                    CustomKeyboard(
                      correctWord: widget.answer,
                      onKeyTap: _onKeyPress,
                      onDelete: _onDelete,
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      data: "KIỂM TRA",
                      backgroundColor: Colors.yellow,
                      textColor: Colors.black,
                      enabled: userInput.length == answerChars.length,
                      onTap: _onCheck,
                    ),
                    const SizedBox(height: 5,),
                  ],
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
}
