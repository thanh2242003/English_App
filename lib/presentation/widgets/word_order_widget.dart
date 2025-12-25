import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/word_order_quiz.dart';
import 'result_popup_widget.dart';

class WordOrderWidget extends StatefulWidget {
  final WordOrderQuiz quizData;
  final VoidCallback onNext;

  const WordOrderWidget({
    super.key,
    required this.quizData,
    required this.onNext,
  });

  @override
  State<WordOrderWidget> createState() => _WordOrderWidgetState();
}

class _WordOrderWidgetState extends State<WordOrderWidget> {
  bool _showResult = false;
  bool _isCorrect = false;
  final List<String> _userAnswerWords = [];

  // Text-to-speech
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _speakSentence(String sentence) async {
    // Dừng bất kỳ phát âm nào đang diễn ra
    await flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    await flutterTts.speak(sentence);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _checkAnswer() {
    final userAnswerString = _userAnswerWords.join(" ");
    final correctAnswerString = widget.quizData.correctOrder.join(" ");

    if (userAnswerString.toLowerCase() == correctAnswerString.toLowerCase()) {
      setState(() {
        _isCorrect = true;
        _showResult = true;
      });

      // Phát âm câu hoàn chỉnh khi đúng
      Future.delayed(const Duration(milliseconds: 200), () {
        _speakSentence(correctAnswerString);
      });
    } else {
      setState(() {
        _isCorrect = false;
        _showResult = true;
      });
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          _reset();
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _userAnswerWords.clear(); // Xóa câu trả lời để thử lại
    });
  }

  Widget _buildResultBox() {
    if (_isCorrect) {
      return ResultPopupWidget(
        message: "Chính xác!",
        correctAnswer: widget.quizData.correctOrder.join(' '),
        englishText: widget.quizData.correctOrder.join(' '),
        onNext: () {
          setState(() {
            _showResult = false;
            _userAnswerWords.clear();
          });
          widget.onNext(); // Chuyển sang câu hỏi mới
        },
      );
    } else {
      // Khi sai hiển thị text sai
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
    final List<String> optionWords = List.from(widget.quizData.words)
      ..removeWhere((word) => _userAnswerWords.contains(word));

    final bool isCheckButtonEnabled = _userAnswerWords.isNotEmpty;

    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  widget.quizData.vietnamese,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(8),
                  height: 60,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white24, width: 2),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _userAnswerWords
                        .map(
                          (word) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A3939),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _userAnswerWords.remove(word);
                              });
                            },
                            child: Text(word, style: const TextStyle(fontSize: 18)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: optionWords
                      .map(
                        (word) => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A3939),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            // Phát âm từ tiếng anh khi nhấn chọn
                            _speak(word);
                            setState(() {
                              _userAnswerWords.add(word);
                            });
                          },
                          child: Text(
                            word,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isCheckButtonEnabled ? _checkAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckButtonEnabled
                          ? Colors.yellow
                          : Colors.grey[700],
                      foregroundColor: isCheckButtonEnabled
                          ? Colors.black
                          : Colors.grey[400],
                    ),
                    child: const Text(
                      "KIỂM TRA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
        if (_showResult) _buildResultBox(),
      ],
    );
  }
}
