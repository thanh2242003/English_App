import 'package:english_app/data/match_words_data.dart';
import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'dart:math';

class LessonMatchWidget extends StatefulWidget {
  const LessonMatchWidget({super.key, required this.data});
  final MatchWordsData data;

  @override
  State<LessonMatchWidget> createState() => _LessonMatchWidgetState();
}

class _LessonMatchWidgetState extends State<LessonMatchWidget> {
  late List<String> englishWords;
  late List<String> vietnameseWords;

  String? selectedEnglish;
  String? selectedVietnamese;
  Set<String> matched = {};

  // highlight map lưu trạng thái màu từng từ
  Map<String, Color> englishHighlight = {};
  Map<String, Color> vietnameseHighlight = {};

  bool shuffled = false;

  @override
  void initState() {
    super.initState();
    englishWords = widget.data.wordMap.keys.toList();
    vietnameseWords = widget.data.wordMap.values.toList();

    // khởi tạo map highlight (trắng ban đầu)
    for (var e in englishWords) {
      englishHighlight[e] = Colors.white;
    }
    for (var v in vietnameseWords) {
      vietnameseHighlight[v] = Colors.white;
    }
  }

  void shuffleVietnamese() {
    setState(() {
      vietnameseWords.shuffle(Random());
      shuffled = true;
    });
  }

  void onEnglishTap(String en) {
    if (matched.contains(en)) return;
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
    final correctVN = widget.data.wordMap[selectedEnglish!];
    if (vn == correctVN) {
      // đúng
      setState(() {
        englishHighlight[currentEnglish] = Colors.green;
        vietnameseHighlight[vn] = Colors.green;
        selectedEnglish = null;
        selectedVietnamese = null; // để highlight xanh
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          matched.add(currentEnglish); // disable sau 0.5s
          englishHighlight[currentEnglish] = Colors.grey;
          vietnameseHighlight[vn] = Colors.grey;
        });
      });
    } else {
      // sai
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
                  // English column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: englishWords.map((en) {
                      final isMatched = matched.contains(en);
                      final isSelected = selectedEnglish == en;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 120,
                        child: MyButton(
                          data: en,
                          textColor: englishHighlight[en] ?? Colors.white,
                          borderColor: Colors.transparent,
                          backgroundColor: const Color(0xFF3A3939),
                          enabled: !isMatched && shuffled,
                          onTap: () => onEnglishTap(en),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 50),
                  // Vietnamese column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: vietnameseWords.map((vn) {
                      final isMatched = matched.any((en) => widget.data.wordMap[en] == vn);
                      final isSelected = selectedVietnamese == vn;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 120,
                        child: MyButton(
                          data: vn,
                          textColor: vietnameseHighlight[vn] ?? Colors.white,
                          borderColor: Colors.transparent,
                          backgroundColor: const Color(0xFF3A3939),
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
            // Bottom Button
            MyButton(
              data: allMatched
                  ? "Tiếp theo"
                  : (shuffled ? "Đang chơi" : "Xáo trộn"),
              textColor: allMatched || shuffled ? Colors.white : Colors.black,
              backgroundColor: allMatched ? Colors.green : Colors.yellow,
              enabled: shuffled ? allMatched : true,
              onTap: () {
                if (allMatched) {
                  // TODO: chuyển sang màn tiếp theo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Qua màn tiếp theo!")),
                  );
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
