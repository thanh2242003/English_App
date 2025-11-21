import '../../domain/entities/onboarding_question.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../onboarding_questions_data.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<List<OnboardingQuestion>> getQuestions() async {
    return onboardingQuestions;
  }
}


