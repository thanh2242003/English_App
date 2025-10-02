// import 'dart:math';
// import 'package:english_app/core/widgets/my_button.dart';
// import 'package:english_app/data/lesson_data.dart';
// import 'package:english_app/presentation/screens/home_screen.dart';
// import 'package:flutter/material.dart';
//
// class LessonQuestionsScreen extends StatefulWidget {
//   const LessonQuestionsScreen({super.key});
//
//   @override
//   State<LessonQuestionsScreen> createState() => _LessonQuestionsScreenState();
// }
//
// class _LessonQuestionsScreenState extends State<LessonQuestionsScreen> {
//   double progress = 0.2;
//
//   String? selectedEnglish;
//
//   // shuffled list of Vietnamese meanings
//   List<String> shuffledVietnamese = <String>[];
//
//   // set of English words that have been matched (never null)
//   final Set<String> matchedEnglish = <String>{};
//
//   bool shuffled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // khởi tạo danh sách nghĩa (ban đầu giữ nguyên thứ tự)
//     shuffledVietnamese = words.map((w) => w.vietnamese).toList();
//   }
//
//   void shuffleVietnamese() {
//     final temp = List<String>.from(shuffledVietnamese);
//     temp.shuffle(Random());
//     setState(() {
//       shuffledVietnamese = temp;
//       shuffled = true;
//       matchedEnglish.clear(); // reset các match khi shuffle lại
//       selectedEnglish = null;
//     });
//   }
//
//   void onEnglishTap(String english) {
//     // nếu đã match rồi thì bỏ qua
//     if (matchedEnglish.contains(english)) return;
//     setState(() {
//       // chọn/đổi lựa chọn english
//       if (selectedEnglish == english) {
//         selectedEnglish = null;
//       } else {
//         selectedEnglish = english;
//       }
//     });
//   }
//
//   void onVietnameseTap(String vn) {
//     if (selectedEnglish == null) return; // chưa chọn english thì không làm gì
//
//     // tìm index của từ english đã chọn trong danh sách original
//     final idx = words.indexWhere(
//       (w) => w.english == selectedEnglish,
//     ); // -1 nếu không tìm
//     if (idx == -1) {
//       // không tìm thấy (không nên xảy ra nếu dữ liệu đúng)
//       setState(() {
//         selectedEnglish = null;
//       });
//       return;
//     }
//
//     final correctVN = words[idx].vietnamese;
//
//     setState(() {
//       if (vn == correctVN) {
//         // đúng -> lưu english đã match
//         matchedEnglish.add(selectedEnglish!);
//         // optional: show small feedback
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Chính xác ✅")));
//       } else {
//         // sai -> feedback
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Sai rồi, thử lại ❌")));
//       }
//       // reset selection
//       selectedEnglish = null;
//     });
//   }
//
//   bool get allMatched => matchedEnglish.length == words.length;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               child: LinearProgressIndicator(
//                 value: progress,
//                 backgroundColor: const Color(0xFF3A3939),
//                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
//                 minHeight: 15,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             const Text(
//               "Từ vựng của bài học",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: SingleChildScrollView(
//                 // cho phòng trường hợp nhiều từ vẫn cuộn được
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // English column
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: words.map((word) {
//                         final matched = matchedEnglish.contains(word.english);
//                         final isSelected = selectedEnglish == word.english;
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           width: 140,
//                           child: MyButton(
//                             data: word.english,
//                             textColor: Colors.white,
//                             backgroundColor: matched
//                                 ? Colors.green.shade700
//                                 : (isSelected
//                                       ? Colors.blue
//                                       : const Color(0xFF3A3939)),
//                             enabled: !matched,
//                             onTap: () => onEnglishTap(word.english),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(width: 50),
//                     // Vietnamese column (dùng shuffledVietnamese)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: shuffledVietnamese.map((vn) {
//                         // kiểm tra xem nghĩa này có đã được match chưa:
//                         final matched = matchedEnglish.any((eng) {
//                           final idx = words.indexWhere((w) => w.english == eng);
//                           return idx != -1 && words[idx].vietnamese == vn;
//                         });
//                         return Container(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           width: 140,
//                           child: MyButton(
//                             data: vn,
//                             textColor: Colors.white,
//                             backgroundColor: matched
//                                 ? Colors.green.shade700
//                                 : const Color(0xFF3A3939),
//                             enabled: !matched && shuffled,
//                             // chỉ cho chọn khi đã shuffle
//                             onTap: () => onVietnameseTap(vn),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             MyButton(
//               data: shuffled ? 'Tiếp theo' : 'Xáo trộn',
//               backgroundColor: Colors.yellow,
//               textColor: Colors.white,
//               borderColor: Colors.transparent,
//               enabled: shuffled ? allMatched : true,
//               onTap: () {
//                 if (!shuffled) {
//                   shuffleVietnamese();
//                 } else if (allMatched) {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(builder: (context) => HomeScreen()),
//                   // );
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
