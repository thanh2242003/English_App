import '../../data/auth_service.dart';
import '../../data/offline_data_service.dart';
import '../../data/progress_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/auth/observe_auth_state.dart';
import '../../domain/usecases/auth/sign_in_with_email.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up_with_email.dart';
import '../../domain/usecases/lesson/get_all_lessons.dart';
import '../../domain/usecases/lesson/get_lesson_by_id.dart';
import '../../domain/usecases/lesson/initialize_offline_data.dart';
import '../../domain/usecases/onboarding/get_onboarding_questions.dart';
import '../../domain/usecases/progress/get_completed_lessons.dart';
import '../../domain/usecases/progress/get_current_progress.dart';
import '../../domain/usecases/progress/get_progress_for_lesson.dart';
import '../../domain/usecases/progress/mark_lesson_completed.dart';
import '../../domain/usecases/progress/mark_part_completed.dart';
import '../../domain/usecases/progress/restart_lesson_progress.dart';
import '../../domain/usecases/progress/save_progress.dart';

class AppDependencies {
  AppDependencies._internal();

  static final AppDependencies _instance = AppDependencies._internal();

  factory AppDependencies() => _instance;

  late final OfflineDataService _offlineDataService;
  late final ProgressService _progressService;
  late final AuthService _authService;

  late final LessonRepository lessonRepository;
  late final ProgressRepository progressRepository;
  late final AuthRepository authRepository;
  late final OnboardingRepository onboardingRepository;

  late final InitializeOfflineData initializeOfflineData;
  late final GetAllLessons getAllLessons;
  late final GetLessonById getLessonById;

  late final SaveProgress saveProgress;
  late final MarkPartCompleted markPartCompleted;
  late final GetCurrentProgress getCurrentProgress;
  late final GetProgressForLesson getProgressForLesson;
  late final RestartLessonProgress restartLessonProgress;
  late final MarkLessonCompleted markLessonCompleted;
  late final GetCompletedLessons getCompletedLessons;

  late final SignInWithEmail signInWithEmail;
  late final SignUpWithEmail signUpWithEmail;
  late final ObserveAuthState observeAuthState;
  late final SignOut signOut;

  late final GetOnboardingQuestions getOnboardingQuestions;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _offlineDataService = OfflineDataService();
    _progressService = ProgressService();
    _authService = AuthService();

    lessonRepository = LessonRepositoryImpl(_offlineDataService);
    progressRepository = ProgressRepositoryImpl(_progressService);
    authRepository = AuthRepositoryImpl(_authService);
    onboardingRepository = OnboardingRepositoryImpl();

    initializeOfflineData = InitializeOfflineData(lessonRepository);
    getAllLessons = GetAllLessons(lessonRepository);
    getLessonById = GetLessonById(lessonRepository);

    saveProgress = SaveProgress(progressRepository);
    markPartCompleted = MarkPartCompleted(progressRepository);
    getCurrentProgress = GetCurrentProgress(progressRepository);
    getProgressForLesson = GetProgressForLesson(progressRepository);
    restartLessonProgress = RestartLessonProgress(progressRepository);
    markLessonCompleted = MarkLessonCompleted(progressRepository);
    getCompletedLessons = GetCompletedLessons(progressRepository);

    signInWithEmail = SignInWithEmail(authRepository);
    signUpWithEmail = SignUpWithEmail(authRepository);
    observeAuthState = ObserveAuthState(authRepository);
    signOut = SignOut(authRepository);

    getOnboardingQuestions = GetOnboardingQuestions(onboardingRepository);

    await initializeOfflineData();
    _initialized = true;
  }
}

