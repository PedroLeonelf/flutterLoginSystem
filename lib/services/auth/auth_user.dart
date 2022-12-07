import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable
class UserAuth {
  final String? email;
  final bool isEmailVerified;
  const UserAuth(this.isEmailVerified, this.email);

  factory UserAuth.fromFirebase(User user) => UserAuth(user.emailVerified, user.email);
}
