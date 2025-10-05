import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  
  // Text-to-speech
  FlutterTts flutterTts = FlutterTts();
  //bool _isSpeaking = false;

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
    // Dừng bất kỳ phát âm nào đang diễn ra trước khi phát âm từ mới
    await flutterTts.stop();
    
    // Thêm delay nhỏ để đảm bảo stop hoàn tất
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Tăng tốc độ phát âm khi bấm vào từ
    await flutterTts.setSpeechRate(1.2);
    await flutterTts.speak(text);
    
    // Khôi phục tốc độ bình thường sau khi phát âm xong
    Future.delayed(const Duration(milliseconds: 200), () async {
      await flutterTts.setSpeechRate(0.8);
    });
  }
  
  void _speakSentence(String sentence) async {
    // Dừng bất kỳ phát âm nào đang diễn ra
    await flutterTts.stop();
    
    // Thêm delay nhỏ để đảm bảo stop hoàn tất
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Phát âm câu với tốc độ bình thường
    await flutterTts.setSpeechRate(0.8);
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
      Future.delayed(const Duration(milliseconds: 300), () {
        _speakSentence(correctAnswerString);
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _isCorrect ? Colors.green : Colors.red,
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
            if (_isCorrect) ...[
              Text(
                widget.quizData.correctOrder.join(' '),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 16),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ],
        ),
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
                              // Phát âm từ tiếng Anh khi nhấn để xóa
                              //_speak(word);
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
                            // Phát âm từ tiếng Anh khi nhấn chọn
                            _speak(word);
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
        if (_showResult) _buildResultBox(),
      ],
    );
  }
}
