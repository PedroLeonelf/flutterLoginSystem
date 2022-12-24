import 'package:firebasetest/constants/routes.dart';
import 'package:firebasetest/services/auth/auth_service.dart';
import 'package:firebasetest/services/crud/notes_services.dart';
import 'package:flutter/material.dart';

import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  //String? get getUserEmail => AuthService.firebase().currentUser!.email;
  String get getUserEmail {
    final String? email = AuthService.firebase().currentUser!.email;
    if (email == null) {
      throw NullEmail;
    }
    return email;
  }

  late final NotesService noteService;

  @override
  void initState() {
    noteService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    noteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your notes'),
        actions: [
          IconButton(
              onPressed: (() {
                Navigator.of(context)
                    .pushNamed(newNotesRoute);
              }),
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: noteService.getOrCreateUsers(email: getUserEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: noteService.allNotes,
                  builder: ((context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text('Wainting for all notes...');
                      default:
                        return const CircularProgressIndicator();
                    }
                  }));
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class NullEmail implements Exception {}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              child: Text('Yes'),
              onPressed: (() {
                Navigator.of(context).pop(true);
              })),
          TextButton(
            child: Text('No'),
            onPressed: (() {
              Navigator.of(context).pop(false);
            }),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
