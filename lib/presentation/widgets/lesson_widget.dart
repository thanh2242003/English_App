import 'package:flutter/material.dart';

class LessonWidget extends StatelessWidget {
  const LessonWidget({
    super.key,
    required this.imagePath,
    required this.lessonName,
    required this.lessonTopic,
    required this.onPress,
    this.isCompleted = false,
    this.buttonText = "Bắt đầu",
  });

  final String imagePath, lessonName, lessonTopic;
  final VoidCallback onPress;
  final bool isCompleted;
  final String buttonText;

  // Xác định màu nền nút
  Color _getButtonColor() {
    if (buttonText == "Thử lại") {
      return Colors.orange;
    } else if (buttonText == "Tiếp tục") {
      return Colors.blue;
    } else {
      return Colors.white;
    }
  }

  // Xác định màu chữ nút
  Color _getButtonTextColor() {
    if (buttonText == "Bắt đầu") {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? Colors.green : Color(0xFF2E2D2D), 
          width: 10
        ),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: isCompleted 
            ? ColorFilter.mode(
                Colors.green.withOpacity(0.3),
                BlendMode.overlay,
              )
            : ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lessonName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 200,
            height: 55,
            child: Text(
              lessonTopic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Hàng 3 ngôi sao
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 74, // to hơn để tạo viền
                    color: Colors.white,
                  ),
                  Icon(Icons.star, size: 58, color: Color(0xCCCCCCCD)),
                ],
              ),
            ),
          ),
          // Nút bắt đầu
          ElevatedButton(
            onPressed: onPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(),
              foregroundColor: _getButtonTextColor(),
              shape: StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              buttonText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
