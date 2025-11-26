import '../../entities/auth_user.dart';
import '../../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository _repository;

  const SignInWithEmail(this._repository);

  Future<AuthUser?> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}



