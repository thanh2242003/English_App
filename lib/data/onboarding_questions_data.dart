import '../domain/entities/onboarding_question.dart';

const onboardingQuestions = [
  OnboardingQuestion(
    text: 'Trình độ tiếng Anh của bạn ở mức nào?',
    answers: [
      'Tôi mới bắt đầu học',
      'Tôi biết vài từ',
      'Tôi có thể đọc và nói',
    ],
  ),
  OnboardingQuestion(
    text: 'Vì sao bạn muốn học tiếng Anh?',
    answers: [
      'Để thoải mái đi du lịch',
      'Để đậu các kỳ thi',
      'Để xem phim, đọc sách',
      'Cho vui',
    ],
  ),
  OnboardingQuestion(
    text: 'Thiết lập mục tiêu',
    answers: [
      '5 phút mỗi ngày',
      '10 phút mỗi ngày',
      '15 phút mỗi ngày',
      '30 phút mỗi ngày',
    ],
  ),
];
