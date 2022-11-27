import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

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
          title: Text('Register'),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return getConnection();
              default:
                return Text('Loading');
            }
          },
        ));
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
                final userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: pass);
                print(userCredential);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  print("Weak password!");
                } else if (e.code == 'email-already-in-use') {
                  print('Email in use.');
                }
              }
            },
            child: Text('Register')),
      ],
    );
  }
}
