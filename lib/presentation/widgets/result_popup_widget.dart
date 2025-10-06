import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultPopupWidget extends StatefulWidget {
  final String message;
  final String correctAnswer;
  final VoidCallback onNext;
  final Color backgroundColor;
  final Color textColor;
  final String englishText; // Text tiếng Anh để phát âm

  const ResultPopupWidget({
    super.key,
    required this.message,
    required this.correctAnswer,
    required this.onNext,
    this.backgroundColor = Colors.green,
    this.textColor = Colors.white,
    required this.englishText,
  });

  @override
  State<ResultPopupWidget> createState() => _ResultPopupWidgetState();
}

class _ResultPopupWidgetState extends State<ResultPopupWidget> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _speak(String text) async {
    await flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 50));
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.white;
    final buttonTextColor = widget.backgroundColor;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // thông báo chính xác hay chưa
            Text(
              widget.message,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
             const SizedBox(height: 10),
             //đáp án đúng và nút phát âm
             SizedBox(
               width: double.infinity,
               child: Stack(
                 alignment: Alignment.center,
                 children: [
                   // Text căn giữa
                   Text(
                     widget.correctAnswer,
                     style: TextStyle(color: widget.textColor, fontSize: 18),
                     textAlign: TextAlign.center,
                   ),
                   // Nút phát âm ở bên phải
                   Positioned(
                     right: 0,
                     child: GestureDetector(
                       onTap: () => _speak(widget.englishText),
                       child: Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Icon(
                           Icons.volume_up,
                           color: widget.textColor,
                           size: 24,
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
            //nút tiếp theo
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
              ),
              onPressed: widget.onNext,
              child: const Text(
                "Tiếp theo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
