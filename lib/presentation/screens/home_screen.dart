import 'package:english_app/core/widgets/my_button.dart';
import 'package:english_app/presentation/widgets/lesson_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double progress = 0.5;
    return Scaffold(
      body: SafeArea(
        child: Container(
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
                    SizedBox(height: 10,),
                    //chuỗi ngày
                    Icon(Icons.local_fire_department, color: Colors.orange, size: 45),
                    Text(
                      'Chuỗi ngày: 1',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    //tiến độ bài học
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Transform.rotate(
                            angle: 3.14,
                            child: CircularProgressIndicator(
                              value: 0.6, // 70%
                              strokeWidth: 8,
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.yellow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        //cấp độ
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF3C3745),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Tiến độ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                    // Vòng tròn chính giữa
                    SizedBox(
                      height: 270,
                      child: PageView(
                        controller: PageController(viewportFraction: 0.8),
                        children: [
                          LessonWidget(
                            imagePath: 'assets/images/lesson_background_image_1.jpg',
                            lessonName: 'Bài học 1',
                            lessonTopic: 'Thì hiện tại: câu khẳng định',
                          ),
                          LessonWidget(
                            imagePath: 'assets/images/lesson_background_image_2.jpg',
                            lessonName: 'Bài học 2',
                            lessonTopic: 'Danh từ số nhiều',
                          ),
                          LessonWidget(
                            imagePath: 'assets/images/lesson_background_image_3.jpg',
                            lessonName: 'Bài học 3',
                            lessonTopic: 'Thì hiện tại: câu nghi vấn',
                          ),
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
                iconSize: 40,
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
          ),
      ),
    );
  }
}
