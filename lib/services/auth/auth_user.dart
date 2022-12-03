import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable
class UserAuth {
  final bool isEmailVerified;
  const UserAuth(this.isEmailVerified);

  factory UserAuth.fromFirebase(User user) => UserAuth(user.emailVerified);
}
