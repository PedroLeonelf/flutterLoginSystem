import 'dart:developer';

import 'package:firebasetest/constants/routes.dart';
import 'package:firebasetest/services/auth/auth_exceptions.dart';
import 'package:firebasetest/services/auth/auth_service.dart';
import 'package:firebasetest/utilities/show_error_dialog.dart';

import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: getConnection());
  }

  Widget getConnection() {
    return Column(
      children: [
        TextField(
          autofillHints: AutofillHints.email.characters,
          controller: _email,
          decoration: const InputDecoration(hintText: "Enter your email here:"),
        ),
        TextField(
          controller: _pass,
          decoration:
              const InputDecoration(hintText: 'Enter your password here:'),
        ),
        TextButton(
            onPressed: () async {
              final email = _email.text;
              final pass = _pass.text;
              try {
                await AuthService.firebase()
                      .createUser(email: email, password: pass);
                  final user = AuthService.firebase().currentUser;
                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyEmail);

                } on WeakPasswordException{
                  await showErrorDialog(context, 'Weak passord!'); 
                } on EmailAlreadyInUse{
                  await showErrorDialog(context, 'Email in use!');
                } on GenericException{
                  await showErrorDialog(context, 'Authentication Exception');
              }
              
              } 
            ,
            child: const Text('Register')),
        TextButton(
          child: const Text('Login here!'),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (route) => false);
          },
        )
      ],
    );
  }
}
