import 'auth_provider.dart';
import 'auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  @override
  Future<UserAuth> createUser({
    required String email,
    required String password,
  }) =>
      createUser(email: email, password: password);

  @override
  UserAuth? get currentUser => provider.currentUser;

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<UserAuth> login({
    required String email,
    required String password,
  }) =>
      provider.login(email: email, password: password);

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
