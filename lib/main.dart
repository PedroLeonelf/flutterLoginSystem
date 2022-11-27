// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasetest/firebase_options.dart';
import 'package:firebasetest/views/login.dart';
import 'package:flutter/material.dart';

const apiKey = "AIzaSyA7kGxBE4jHk8wPFj8M-nmUChTOCDsTo6Q";
const projectId = "lionyxfirstfirebase";
void main(List<String> args) async {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;

              if (user?.emailVerified ?? false) {
                print('Verified.');
              } else {
                print('Need to verify your email.');
              }

              return const Text('Done');
            default:
              return const Text('Loading...');
          }
        }),
      ),
    );
  }
}
