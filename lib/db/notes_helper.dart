import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo_notes_thign/models/note.dart';
import 'package:todo_notes_thign/provider/note_provider.dart';

final String tableName = 'note';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnCreatedAt = 'createdAt';
final String columnContent = 'content';
final String columnColorIndex = 'gradientColorIndex';

class NotesHelper {
  static late Database _database;

  static NotesHelper _notesHelper = NotesHelper();

  NotesHelper._createInstance();
  factory NotesHelper() {
    _notesHelper = NotesHelper._createInstance();

    return _notesHelper;
  }

  Future<Database> get database async {
    _database = await initializeDatabase();

    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "/note.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableName (
          $columnId text primary key,
          $columnTitle text not null,
          $columnCreatedAt text not null,
          $columnContent text not null,
          $columnColorIndex integer)
        ''');
      },
    );

    return database;
  }

  Future<Note> getNoteById(String id) async {
    final db = await database;
    var result = await db.query(
      tableName,
      where: "id=?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Note.fromJson(result.first);
    } else {
      throw Exception("$id NOT FOUND");
    }
  }

  Future<void> insertNote(Note note) async {
    var db = await this.database;
    var result = await db.insert(tableName, note.toJson());

    print(result);
  }

  Future<void> deleteNote(String id) async {
    var db = await this.database;
    var result = await db.delete(tableName, where: "id = ?", whereArgs: [id]);
    print(result);
  }

  Future<void> saveNoteTitle(Note note) async {
    var db = await this.database;
    var result =
        await db.update(tableName, note.toJson(), where: "title=?", whereArgs: [
      note.title,
    ]);

    print(result);
  }

  Future<void> saveContent(Note note) async {
    var db = await this.database;

    var result = await db
        .update(tableName, note.toJson(), where: "id=?", whereArgs: [note.id]);

    print(result);
  }

  Future<List<Note>> getNotes(BuildContext context) async {
    List<Note> _notes = [];
    var db = await this.database;
    var result = await db.query(
      tableName,
      orderBy: "createdAt DESC",
    );

    result.forEach((element) {
      var noteInfo = Note.fromJson(element);
      _notes.add(noteInfo);
    });

    return _notes;
  }
}
