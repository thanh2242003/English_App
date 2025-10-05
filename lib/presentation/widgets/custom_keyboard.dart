import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final String correctWord;
  final void Function(String) onKeyTap;
  final VoidCallback onDelete;

  const CustomKeyboard({
    super.key,
    required this.correctWord,
    required this.onKeyTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy ra danh sách ký tự hợp lệ
    final allowedLetters = correctWord.toLowerCase().split('').toSet();

    // Bố cục 3 hàng bàn phím
    const keyboardRows = [
      "qwertyuiop",
      "asdfghjkl",
      "zxcvbnm",
    ];

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tạo từng hàng phím
          for (var row in keyboardRows)
            _buildRow(row, allowedLetters, context),

          const SizedBox(height: 8),

          // Hàng cuối có nút XÓA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "XÓA",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tạo từng hàng phím
  Widget _buildRow(String letters, Set<String> allowedLetters, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var letter in letters.split(''))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ElevatedButton(
                onPressed: allowedLetters.contains(letter)
                    ? () => onKeyTap(letter)
                    : null, // disable nếu không có trong từ
                style: ElevatedButton.styleFrom(
                  backgroundColor: allowedLetters.contains(letter)
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey[800],
                  disabledBackgroundColor: Colors.grey[800],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(38, 48),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 18,
                    color: allowedLetters.contains(letter)
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
