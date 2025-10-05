import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/word_order_quiz.dart';

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

  void _checkAnswer() {
    final userAnswerString = _userAnswerWords.join(" ");
    final correctAnswerString = widget.quizData.correctOrder.join(" ");

    if (userAnswerString.toLowerCase() == correctAnswerString.toLowerCase()) {
      setState(() {
        _isCorrect = true;
        _showResult = true;
      });
    } else {
      setState(() {
        _isCorrect = false;
        _showResult = true;
      });
      Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _reset();
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _userAnswerWords.clear(); // Xóa câu trả lời để người dùng thử lại
    });
  }

  Widget _buildResultBox() {
    if (!_showResult) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _isCorrect
            ? Colors.green.withOpacity(0.9)
            : Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isCorrect ? "Chính xác!" : "Chưa chính xác!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_isCorrect)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showResult = false;
                  _userAnswerWords.clear();
                });
                widget.onNext(); // Chuyển sang câu hỏi mới
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
              ),
              child: const Text(
                "TIẾP TỤC",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Khởi tạo optionWords trong build, loại bỏ các từ đã được chọn trong _userAnswerWords
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
                  textAlign: TextAlign.center,
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
                            child: Text(word),
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
                  alignment: WrapAlignment.center,
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
                            setState(() {
                              _userAnswerWords.add(word);
                            });
                          },
                          child: Text(word),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
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
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: _buildResultBox(),
          ),
        ),
      ],
    );
  }
}
