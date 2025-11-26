import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class ObserveAuthState {
  final AuthRepository _repository;

  const ObserveAuthState(this._repository);

  Stream<AuthUser?> call() {
    return _repository.authStateChanges();
  }
}



