import 'package:flutter/material.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/data/lesson_data.dart';
import 'dart:math';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late List<String> englishWords;
  late List<String> vietnameseWords;

  String? selectedEnglish;
  String? selectedVietnamese;
  Set<String> matched = {};

  bool shuffled = false;

  @override
  void initState() {
    super.initState();
    englishWords = wordMap.keys.toList();
    vietnameseWords = wordMap.values.toList();
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
      selectedEnglish = en;
    });
  }

  void onVietnameseTap(String vn) {
    if (selectedEnglish == null) return;

    final correctVN = wordMap[selectedEnglish!];
    if (vn == correctVN) {
      // đúng
      setState(() {
        matched.add(selectedEnglish!);
        selectedEnglish = null;
        selectedVietnamese = null;
      });
    } else {
      // sai
      setState(() {
        selectedVietnamese = vn;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: LinearProgressIndicator(
                value: matched.length / englishWords.length,
                backgroundColor: const Color(0xFF3A3939),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                minHeight: 15,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Text(
              "Từ vựng của bài học",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
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
                          textColor: isMatched
                              ? Colors.green
                              : (isSelected ? Colors.yellow : Colors.white),
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
                      final isMatched = matched.any((en) => wordMap[en] == vn);
                      final isSelected = selectedVietnamese == vn;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 120,
                        child: MyButton(
                          data: vn,
                          textColor: isMatched
                              ? Colors.green
                              : (isSelected ? Colors.red : Colors.white),
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
