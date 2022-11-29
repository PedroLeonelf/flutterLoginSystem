import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasetest/constants/routes.dart';

import 'package:flutter/material.dart';

import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: getConnection(),
    );
  }

  Widget getConnection() {
    return Column(
      children: [
        TextField(
          autofillHints: AutofillHints.email.characters,
          controller: _email,
          decoration: InputDecoration(hintText: "Enter your email here:"),
        ),
        TextField(
          controller: _pass,
          decoration: InputDecoration(hintText: 'Enter your password here:'),
        ),
        TextButton(
            onPressed: () async {
              final email = _email.text;
              final pass = _pass.text;
              try {
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: email, password: pass);
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(notesRoute, (route) => false);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  await showErrorDialog(context, 'User not found!');
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(context, 'Wrong password!');
                } else {
                  await showErrorDialog(context, '$e.code');
                }
              }
            },
            child: const Text('Login')),
        TextButton(
          child: const Text('Register here!'),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/register/', (route) => false);
          },
        ),
      ],
    );
  }
}


