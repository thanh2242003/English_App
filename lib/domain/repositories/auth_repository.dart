import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> signInWithEmail({required String email, required String password});

  Future<AuthUser?> signUpWithEmail({required String email, required String password});

  Future<void> signOut();

  Stream<AuthUser?> authStateChanges();
}


