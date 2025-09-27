import 'package:english_app/core/my_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double progress = 0.5;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF261543), Colors.black],
          begin: Alignment.topCenter,
          end: AlignmentGeometry.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //mục tiêu ngày
              Container(
                margin: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Mục tiêu ngày:  10 phút',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // progress bar dài bằng text
                    SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black,
                        color: Colors.green,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.local_fire_department, color: Colors.orange, size: 45),
              Text(
                'Chuỗi ngày: 1',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              //chuỗi ngày
              const SizedBox(height: 20),
              //tiến độ bài học
              SizedBox(
                width: 100,
                height: 100,
                child: Transform.rotate(
                  angle: 3.14,
                  child: CircularProgressIndicator(
                    value: 0.6, // 70%
                    strokeWidth: 8,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //cấp độ
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Cấp độ 1',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Vòng tròn chính giữa
              Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 10),
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/lesson_background_image_1.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Bài học 1",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Thì hiện tại đơn",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            Icon(
                              Icons.star,
                              size: 60,
                              color: Color(0xCCCCCCCD),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),

                    // Nút bắt đầu
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Bắt đầu",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom navigation
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          currentIndex: 0,
          onTap: (index) {},
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: "Ranking",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
