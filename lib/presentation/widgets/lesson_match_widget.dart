import 'package:english_app/models/match_word_quiz.dart';
import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class LessonMatchWidget extends StatefulWidget {
  const LessonMatchWidget({
    super.key,
    required this.data,
    required this.onNext,
  });

  final MatchWordsQuiz data;
  final VoidCallback onNext;

  @override
  State<LessonMatchWidget> createState() => _LessonMatchWidgetState();
}

class _LessonMatchWidgetState extends State<LessonMatchWidget> {
  late List<String> englishWords;
  late List<String> vietnameseWords;

  String? selectedEnglish;
  String? selectedVietnamese;
  Set<String> matched = {};

  // Lưu màu từng từ
  Map<String, Color> englishHighlight = {};
  Map<String, Color> vietnameseHighlight = {};

  bool shuffled = false;
  bool showResult = false;
  
  // Text-to-speech
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    englishWords = widget.data.wordMap.keys.toList();
    vietnameseWords = widget.data.wordMap.values.toList();

    for (var e in englishWords) {
      englishHighlight[e] = Colors.white;
    }
    for (var v in vietnameseWords) {
      vietnameseHighlight[v] = Colors.white;
    }

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
  
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void shuffleVietnamese() {
    setState(() {
      vietnameseWords.shuffle(Random());
      shuffled = true;
    });
  }

  void onEnglishTap(String en) {
    if (matched.contains(en)) return;
    
    // Phát âm từ tiếng Anh
    _speak(en);
    
    setState(() {
      if (selectedEnglish != null && selectedEnglish != en) {
        englishHighlight[selectedEnglish!] = Colors.white;
      }
      selectedEnglish = en;
      englishHighlight[en] = Colors.yellow;
    });
  }

  void onVietnameseTap(String vn) {
    if (selectedEnglish == null) return;

    final currentEnglish = selectedEnglish!;
    final correctVN = widget.data.wordMap[currentEnglish];

    if (vn == correctVN) {
      // Đúng
      setState(() {
        englishHighlight[currentEnglish] = Colors.green;
        vietnameseHighlight[vn] = Colors.green;
        selectedEnglish = null;
        selectedVietnamese = null;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          matched.add(currentEnglish);
          englishHighlight[currentEnglish] = Colors.grey;
          vietnameseHighlight[vn] = Colors.grey;
        });
      });
    } else {
      // Sai
      setState(() {
        selectedVietnamese = vn;
        englishHighlight[currentEnglish] = Colors.red;
        vietnameseHighlight[vn] = Colors.red;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          englishHighlight[currentEnglish] = Colors.white;
          vietnameseHighlight[vn] = Colors.white;
          selectedVietnamese = null;
          selectedEnglish = null;
        });
      });
    }
  }

  bool get allMatched => matched.length == englishWords.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cột tiếng Anh
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: englishWords.map((en) {
                      final isMatched = matched.contains(en);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 120,
                        child: MyButton(
                          data: en,
                          textColor: englishHighlight[en] ?? Colors.white,
                          backgroundColor: const Color(0xFF3A3939),
                          borderColor: Colors.transparent,
                          enabled: !isMatched && shuffled,
                          onTap: () => onEnglishTap(en),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 50),
                  // Cột tiếng Việt
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: vietnameseWords.map((vn) {
                      final isMatched = matched.any(
                              (en) => widget.data.wordMap[en] == vn);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 120,
                        child: MyButton(
                          data: vn,
                          textColor: vietnameseHighlight[vn] ?? Colors.white,
                          backgroundColor: const Color(0xFF3A3939),
                          borderColor: Colors.transparent,
                          enabled: !isMatched && shuffled,
                          onTap: () => onVietnameseTap(vn),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Nút bên dưới
            MyButton(
              data: allMatched
                  ? "Tiếp theo"
                  : (shuffled ? "Đang chơi" : "Xáo trộn"),
              textColor: Colors.white,
              backgroundColor:
              allMatched ? Colors.green : (shuffled ? Colors.yellow : Colors.blueAccent),
              enabled: allMatched || !shuffled,
              onTap: () {
                if (allMatched) {
                  widget.onNext();
                } else {
                  shuffleVietnamese();
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
