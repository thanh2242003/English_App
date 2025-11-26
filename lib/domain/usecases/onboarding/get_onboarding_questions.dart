import '../../entities/onboarding_question.dart';
import '../../repositories/onboarding_repository.dart';

class GetOnboardingQuestions {
  final OnboardingRepository _repository;

  const GetOnboardingQuestions(this._repository);

  Future<List<OnboardingQuestion>> call() {
    return _repository.getQuestions();
  }
}



