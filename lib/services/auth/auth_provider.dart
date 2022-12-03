import 'package:firebasetest/services/auth/auth_user.dart';

abstract class AuthProvider {
  UserAuth? get currentUser;
  Future<UserAuth> login({
    required String email,
    required String password,
  });

  Future<UserAuth> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}
