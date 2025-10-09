import 'package:english_app/data/progress_service.dart';
import 'package:english_app/models/user_progress.dart';
import 'package:english_app/presentation/screens/exercise_screen.dart';
import 'package:english_app/presentation/widgets/lesson_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  final ProgressService _progressService = ProgressService();
  UserProgress? _userProgress;
  List<String> _completedLessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      _userProgress = await _progressService.getCurrentProgress();
      _completedLessons = await _progressService.getCompletedLessons();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Refresh tiến độ khi quay lại từ lesson
  Future<void> _refreshProgress() async {
    try {
      _userProgress = await _progressService.getCurrentProgress();
      _completedLessons = await _progressService.getCompletedLessons();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh tiến độ khi quay lại màn hình
    _refreshProgress();
  }


  // Tính toán tiến độ tổng thể
  double _calculateOverallProgress() {
    if (_userProgress == null) return 0.0;
    
    // Tính tiến độ dựa trên số lesson đã hoàn thành hoàn toàn
    int totalLessons = 3; // Có 3 bài học
    int completedLessons = _completedLessons.length;
    
    return completedLessons / totalLessons;
  }

  // Kiểm tra lesson đã hoàn thành chưa
  bool _isLessonCompleted(String lessonName) {
    String firebaseLessonName = _mapLessonNameToFirebase(lessonName);
    return _completedLessons.contains(firebaseLessonName);
  }

  // Lấy trạng thái lesson để hiển thị text nút
  String _getLessonButtonText(String lessonName) {
    String firebaseLessonName = _mapLessonNameToFirebase(lessonName);
    if (_isLessonCompleted(firebaseLessonName)) {
      return "Thử lại";
    }
    
    // đã bắt đầu học
    if (_userProgress != null && _userProgress!.lessonTitle == firebaseLessonName) {
      // Kiểm tra nếu đang có part đã hoàn thành
      if (_userProgress!.completedParts.isNotEmpty || 
          _userProgress!.currentPartIndex > 0 || 
          _userProgress!.isPartCompleted) {
        return "Tiếp tục";
      }
    }
    
    return "Bắt đầu";
  }

  // Map tên lesson từ HomeScreen sang Firebase
  String _mapLessonNameToFirebase(String homeScreenName) {
    switch (homeScreenName) {
      case 'Bài học 1':
        return 'Bài 1: Các từ cơ bản';
      case 'Bài học 2':
        return 'Bài 2: Danh từ số nhiều';
      case 'Bài học 3':
        return 'Bài 3: Thì hiện tại câu nghi vấn';
      default:
        return homeScreenName;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    double progress = _calculateOverallProgress();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    //chuỗi ngày
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 45,
                    ),
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
                              value: progress,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
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
                        controller: _pageController,
                        children: [
                          LessonWidget(
                            imagePath:
                                'assets/images/lesson_background_image_1.jpg',
                            lessonName: 'Bài học 1',
                            lessonTopic: 'Thì hiện tại: câu khẳng định',
                            isCompleted: _isLessonCompleted('Bài học 1'),
                            buttonText: _getLessonButtonText('Bài học 1'),
                            onPress: () async {
                              // Nếu thử lại thì restart bài học
                              if (_getLessonButtonText('Bài học 1') == "Thử lại") {
                                await _progressService.restartLessonProgress(_mapLessonNameToFirebase('Bài học 1'));
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExerciseScreen(),
                                ),
                              ).then((_) {
                                // Refresh progress khi quay lại từ exercise screen
                                _refreshProgress();
                              });
                            },
                          ),
                          LessonWidget(
                            imagePath:
                                'assets/images/lesson_background_image_2.jpg',
                            lessonName: 'Bài học 2',
                            lessonTopic: 'Danh từ số nhiều',
                            isCompleted: _isLessonCompleted('Bài học 2'),
                            buttonText: _getLessonButtonText('Bài học 2'),
                            onPress: () async {
                              // Nếu thử lại thì restart bài học
                              if (_getLessonButtonText('Bài học 2') == "Thử lại") {
                                await _progressService.restartLessonProgress(_mapLessonNameToFirebase('Bài học 2'));
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExerciseScreen(),
                                ),
                              ).then((_) {
                                // Refresh progress khi quay lại từ exercise screen
                                _refreshProgress();
                              });
                            },
                          ),
                          LessonWidget(
                            imagePath:
                                'assets/images/lesson_background_image_3.jpg',
                            lessonName: 'Bài học 3',
                            lessonTopic: 'Thì hiện tại: câu nghi vấn',
                            isCompleted: _isLessonCompleted('Bài học 3'),
                            buttonText: _getLessonButtonText('Bài học 3'),
                            onPress: () async {
                              // Nếu thử lại thì restart bài học
                              if (_getLessonButtonText('Bài học 3') == "Thử lại") {
                                await _progressService.restartLessonProgress(_mapLessonNameToFirebase('Bài học 3'));
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExerciseScreen(),
                                ),
                              ).then((_) {
                                // Refresh progress khi quay lại từ exercise screen
                                _refreshProgress();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation đã được chuyển sang MainScreen
            ),
          );
  }
}
