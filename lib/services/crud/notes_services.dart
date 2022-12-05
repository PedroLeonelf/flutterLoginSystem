import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

import 'crud_exceptions.dart';

class NotesService {
  Database? db;

  Future<DatabaseNote> updateNote(DatabaseNote note, String text) async {
    final db = _getDatabaseOrThrow();
    await getNote(note.id);
    db.update(noteTable, {
      textColumn: text,
    });

    return await getNote(note.id);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote(int id) async {
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
    return DatabaseNote.fromRow(notes.first);
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(
      noteTable,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = _getDatabaseOrThrow();
    final deletedAccount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedAccount == 0) {
      throw CouldNotDeleteNode();
    }
  }

  Future<DatabaseNote> createNote(DatabaseUser owner) async {
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
