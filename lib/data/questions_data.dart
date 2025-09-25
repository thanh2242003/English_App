class OnboardingQuestion {
  const OnboardingQuestion(this.text, this.answers);
  final String text;
  final List<String> answers ;
}

const questions = [
  OnboardingQuestion('Trình độ tiếng Anh của bạn ở mức nào?', [
    'Tôi mới bắt đầu học',
    'Tôi biết vài từ',
    'Tôi có thể đọc và nói',
  ]),
  OnboardingQuestion('Vì sao bạn muốn học tiếng Anh?', [
    'Để thoải mái đi du lịch',
    'Để đậu các kỳ thi',
    'Để xem phim, đọc sách',
    'Cho vui',
  ]),
  OnboardingQuestion('Thiết lập mục tiêu', [
    '5 phút mỗi ngày',
    '10 phút mỗi ngày',
    '15 phút mỗi ngày',
    '30 phút mỗi ngày',
  ]),
];
