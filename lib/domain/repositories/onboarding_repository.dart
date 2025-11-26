import '../entities/onboarding_question.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingQuestion>> getQuestions();
}



