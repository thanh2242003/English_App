import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
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

  // @override
  // void initState() {
  //   super.initState();
  //   //answerChars = widget.answer.toLowerCase().split('');
  //   String cleanAnswer = widget.answer.toLowerCase().trim();
  //   answerChars = cleanAnswer.split('');
  //   print('widget.answer (raw): "${widget.answer}"'); // In chuỗi gốc
  //   print('widget.answer (clean): "$cleanAnswer"'); // In chuỗi sau khi làm sạch
  //   print('answerChars: $answerChars'); // In danh sách ký tự
  //   print('answerChars.length: ${answerChars.length}'); // In độ dài
  // }

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

    //sai thì popup sai
    if (!isCorrect) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          showResult = false;
          userInput = ''; // Xóa input để người dùng nhập lại
        });
      });
      // Future.delayed(const Duration(seconds: 2), () {
      //   if (widget.onNext != null) widget.onNext!();
      // });
    }
  }

  // Hiển thị popup kết quả
  Widget _buildResultBox(BuildContext context) {
    final color = isCorrect! ? Colors.green[900] : Colors.red;
    final message = isCorrect! ? "🎉 Chính xác!" : "❌ Chưa chính xác!";
    final correctAnswer = "${widget.answer} - ${widget.question}";

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
              color: color,
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
                if (isCorrect) ...[
                  Text(
                    correctAnswer,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          //const SizedBox(height: 16),
          if (isCorrect) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(50, 50),
              ),
              onPressed: () {
                setState(() {
                  showResult = false;
                  userInput = '';
                  isCorrect = false;
                });
                widget.onNext?.call(); // Chuyển sang câu tiếp theo
              },
              child: const Text(
                "Tiếp theo",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: color,
          //     //minimumSize: const Size(double.infinity, 50),
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       showResult = false;
          //       userInput = '';
          //       isCorrect = false;
          //     });
          //     widget.onNext?.call(); // gọi callback để chuyển câu tiếp theo
          //   },
          //   child: const Text(
          //     "Tiếp theo",
          //     style: TextStyle(color: Colors.white, fontSize: 18),
          //   ),
          // ),
          SizedBox(height: 20),
        ],
      ),
    );
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

                // ✅ Gọi bàn phím custom bạn đã có
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
