

import 'package:firebasetest/constants/routes.dart';
import 'package:firebasetest/services/auth/auth_exceptions.dart';
import 'package:firebasetest/services/auth/auth_service.dart';

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
                await AuthService.firebase().login(email: email, password: pass);

                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmail,
                    (route) => false,
                  );
                }
              } on UserNotFoundException{
                await showErrorDialog(context, 'User not found');
              } on WrongPasswordException{
                await showErrorDialog(context, 'Wrong password');
              } on GenericException{
                await showErrorDialog(context, 'Authentification error');
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
