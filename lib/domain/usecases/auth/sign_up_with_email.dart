import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository _repository;

  const SignUpWithEmail(this._repository);

  Future<AuthUser?> call({required String email, required String password}) {
    return _repository.signUpWithEmail(email: email, password: password);
  }
}



