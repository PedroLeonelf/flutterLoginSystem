// ignore_for_file: prefer_const_constructors


import 'package:firebasetest/constants/routes.dart';
import 'package:firebasetest/views/home.dart';
import 'package:firebasetest/views/login.dart';
import 'package:firebasetest/views/notes.dart';
import 'package:firebasetest/views/register.dart';
import 'package:flutter/material.dart';


void main(List<String> args) async {
  runApp(MaterialApp(
    home: HomePage(),
    routes: {
      loginRoute : (context) => const LoginView(),
      registerRoute :(context) => const RegisterView(),
      notesRoute :(context) => const NotesView(),

    },
  ));
}


