import 'package:firebasetest/constants/routes.dart';
import 'package:firebasetest/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text(
              'A email was send to your email.Please verify your email address!'),
          const Text('If you have not receive, press this button below.'),
          TextButton(
            child: const Text('Send email verification'),
            onPressed: () async {
              final user = AuthService.firebase().currentUser;
              await AuthService.firebase().sendEmailVerification();
            },
          ),
          TextButton(
            onPressed: (() async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            }),
            child: Text('Restart'),
          )
        ],
      ),
    );
  }
}
