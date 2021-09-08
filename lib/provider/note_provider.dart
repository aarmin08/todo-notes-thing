import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_notes_thign/db/notes_helper.dart';
import 'package:todo_notes_thign/models/note.dart';

class Notes extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes {
    return [..._notes];
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  NotesHelper helper = NotesHelper();

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await helper.insertNote(note);
    notifyListeners();
  }

  Future<void> saveNoteContent(String content, String title, String id) async {
    var noteToChange = findById(id);
    final Note note = new Note(
      content: content,
      title: title,
      id: id,
      createdAt: noteToChange.createdAt,
      gradientColorIndex: noteToChange.gradientColorIndex,
    );

    await helper.saveContent(note);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    var noteToDelete = findById(id);
    _notes.removeWhere((element) => element.id == noteToDelete.id);
    await helper.deleteNote(id);

    notifyListeners();
  }

  void saveNoteTitle(String content, String id) {
    var noteToChange = findById(id);
    noteToChange.title = content;

    notifyListeners();
  }

  Note findById(String id) {
    return _notes.firstWhere((element) => element.id == id,
        orElse: () => Note(
            gradientColorIndex: Random().nextInt(5),
            content: "",
            title: "Not found",
            createdAt: DateFormat.yMEd().format(DateTime.now()),
            id: getRandomString(20)));
  }
}
