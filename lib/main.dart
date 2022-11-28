// ignore_for_file: prefer_const_constructors


import 'package:firebasetest/views/home.dart';
import 'package:firebasetest/views/login.dart';
import 'package:firebasetest/views/register.dart';
import 'package:flutter/material.dart';

const apiKey = "AIzaSyA7kGxBE4jHk8wPFj8M-nmUChTOCDsTo6Q";
const projectId = "lionyxfirstfirebase";
void main(List<String> args) async {
  runApp(MaterialApp(
    home: HomePage(),
    routes: {
      '/login/' : (context) => const LoginView(),
      '/register/' :(context) => const RegisterView(),

    },
  ));
}


