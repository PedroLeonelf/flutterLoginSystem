import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

import 'crud_exceptions.dart';

class NotesService {
  Database? db;
  List<DatabaseNote> notesList = [];


  //singleton
  static final NotesService shared = NotesService.sharedInstance();
  NotesService.sharedInstance();
  factory NotesService() => shared; 

  final notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => notesStreamController.stream;

  Future<void> ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<DatabaseUser> getOrCreateUsers({required String email}) async {
    try {
      final user = await getUser(email);
      return user;
    } on CouldNotFoundUser {
      final createdUser = await createUser(email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cacheNotes() async {
    final allNotes = await getAllNotes();
    notesList = allNotes.toList();
    notesStreamController.add(notesList);
  }

  Future<DatabaseNote> updateNote(DatabaseNote note, String text) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(note.id);
    db.update(noteTable, {
      textColumn: text,
    });

    final updatedNote = await getNote(note.id);
    notesList.removeWhere((element) => element.id == updatedNote.id);
    notesList.add(updatedNote);
    notesStreamController.add(notesList);
    return updatedNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote(int id) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFoundNote();
    }
    final note = DatabaseNote.fromRow(notes.first);
    notesList.removeWhere((element) => element.id == id);
    notesList.add(note);
    notesStreamController.add(notesList);
    return note;
  }

  Future<int> deleteAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(
      noteTable,
    );
    notesList = [];
    notesStreamController.add(notesList);
    return numberOfDeletions;
  }

  Future<void> deleteNote(int id) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedAccount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedAccount == 0) {
      throw CouldNotDeleteNode();
    }
    notesList.removeWhere((note) => note.id == id);
    notesStreamController.add(notesList);
  }

  Future<DatabaseNote> createNote(DatabaseUser owner) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(owner.email);
    // make sure database exists in the database with correct id
    if (dbUser != owner) {
      throw CouldNotFoundUser();
    }

    const text = '';
    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
    });

    final note = DatabaseNote(noteId, owner.id, text);
    notesList.add(note);
    notesStreamController.add(notesList);
    return note;
  }

  Future<void> open() async {
    if (db != null) {
      throw DatabaseAlreadyOpenException;
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final database = await openDatabase(dbPath);
      await database.execute(createUserTable);
      await database.execute(createNoteTable);
      await cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory;
    }
  }

  Future<void> close() async {
    final database = db;
    if (database == null) {
      throw DatabaseIsNotOpen();
    } else {
      await database.close();
      db = null;
    }
  }

  Database _getDatabaseOrThrow() {
    final _db = db;
    if (_db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return _db;
    }
  }

  Future<void> deleteUser(String email) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedAccount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedAccount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser(String email) async {
    await ensureDbIsOpen();
    final _db = _getDatabaseOrThrow();
    final results = await db?.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (results?.isNotEmpty ?? false) {
      throw UserAlreadyExists();
    }
    final userId =
        await db?.insert(userTable, {emailColumn: email.toLowerCase()});

    if (userId == null) {
      throw UserNotCreated();
    }

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser(String email) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFoundUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;

  DatabaseNote(this.id, this.userId, this.text);

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String;

  @override
  toString() => 'Note, ID = $id, userId = $userId, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id")
  );''';
