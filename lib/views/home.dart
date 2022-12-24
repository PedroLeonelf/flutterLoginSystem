
import 'package:firebasetest/services/auth/auth_service.dart';
import 'package:firebasetest/views/login.dart';
import 'package:firebasetest/views/notes/notes.dart';
import 'package:firebasetest/views/verify_email.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: ((context, snapshot,) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }

            default:
              return const CircularProgressIndicator();
          }
        }),
      ),
    );
  }
}
