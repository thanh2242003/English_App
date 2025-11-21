import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AuthUser?> signInWithEmail({required String email, required String password}) async {
    final user = await _authService.signIn(email, password);
    return _mapUser(user);
  }

  @override
  Future<AuthUser?> signUpWithEmail({required String email, required String password}) async {
    final user = await _authService.signUp(email, password);
    return _mapUser(user);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _authService.user.map(_mapUser);
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(id: user.uid, email: user.email);
  }
}


