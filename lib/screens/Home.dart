import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quotes/quote_model.dart';
import 'package:quotes/quotes.dart';
import 'package:todo_notes_thign/Utilities/Greetings.dart';
import 'package:todo_notes_thign/Utilities/utils.dart';
import 'package:todo_notes_thign/constants/delayed_anim.dart';
import 'package:todo_notes_thign/constants/theme.dart';
import 'package:todo_notes_thign/db/notes_helper.dart';
import 'package:todo_notes_thign/models/note.dart';
import 'package:todo_notes_thign/provider/note_provider.dart';
import 'package:todo_notes_thign/screens/note_editor_screen.dart';
import 'package:html/parser.dart';
import 'package:todo_notes_thign/widgets/NoteTile.dart';
import 'package:todo_notes_thign/widgets/quoteWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  NotesHelper helper = NotesHelper();

  Future<List<Note>>? _notes;

  final int delayedAmount = 500;
  late double _scale;
  late AnimationController _controller;

  List<Note> notes = [];

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    _notes = null;
    helper.initializeDatabase().then((v) {
      print('init');
      _notes = helper.getNotes(context);

      _notes!.then((value) {
        value.forEach((element) {
          notes.add(element);
        });
      });
    }).whenComplete(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late String title;

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    final noteData = Provider.of<Notes>(context);

    final color = Colors.white;

    _scale = 1 - _controller.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        toolbarHeight: 70.0,
        centerTitle: false,
        elevation: 0.7,
      ),
      floatingActionButton: DelayedAnimation(
        delay: delayedAmount,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                gradient: LinearGradient(
                  colors: GradientTemplate.gradientTemplate[4].colors,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 27,
              ),
            ),
            onTap: () {
              print(noteData.notes);
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return DelayedAnimation(
                      delay: delayedAmount,
                      child: AlertDialog(
                        title: Text("Title"),
                        content: SingleChildScrollView(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter a Title",
                                ),
                                onChanged: (v) {
                                  if (v == "") {
                                    title = "New Note";
                                  } else {
                                    title = v;
                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  goToNotesScreen(
                                      notes, noteData, context, title);
                                },
                                child: Text("Submit"),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return await _notes!.then((value) {
            value.forEach((element) {
              notes.add(element);
            });
          });
        },
        child: SingleChildScrollView(
            child: _notes != null
                ? Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      DelayedAnimation(
                          child: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              Greetings.showGreetings(),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Avenir'),
                            ),
                          ),
                          delay: delayedAmount),
                      DelayedAnimation(
                        child: QuoteTile(),
                        delay: delayedAmount,
                      ),
                      Divider(),
                      FutureBuilder<List<Note>>(
                          future: _notes,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? ListView(
                                    reverse: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(10),
                                    children: snapshot.data!.map(
                                      (e) {
                                        var gradientColorIndex =
                                            e.gradientColorIndex;
                                        var gradientColor = GradientTemplate
                                            .gradientTemplate[
                                                gradientColorIndex]
                                            .colors;
                                        return DelayedAnimation(
                                            delay: delayedAmount,
                                            child: NoteTile(
                                              key: UniqueKey(),
                                              content: e.content,
                                              gradientColor: gradientColor,
                                              gradientColorIndex:
                                                  gradientColorIndex,
                                              title: e.title,
                                              id: e.id,
                                              createdAt: e.createdAt,
                                              deleteNote: () async {
                                                showDialog(
                                                    context: context,
                                                    builder: (ctx) {
                                                      return AlertDialog(
                                                        content: Text(
                                                          "This cannot be undone",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Avenir"),
                                                        ),
                                                        title: Text(
                                                          "Delete note?",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Avenir"),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                _notes = null;
                                                                noteData
                                                                    .deleteNote(
                                                                        e.id)
                                                                    .then(
                                                                        (value) async {
                                                                  _notes = helper
                                                                      .getNotes(
                                                                          context);
                                                                  await _notes!
                                                                      .then(
                                                                          (value) {
                                                                    value.forEach(
                                                                        (element) {
                                                                      notes.removeWhere((id) =>
                                                                          element
                                                                              .id ==
                                                                          id.id);
                                                                    });
                                                                  }).whenComplete(
                                                                          () {
                                                                    setState(
                                                                        () {});
                                                                  });
                                                                });
                                                                Utilities.showSnackbar(
                                                                    context,
                                                                    "Deleted",
                                                                    Colors
                                                                        .amber);
                                                              },
                                                              child: Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "Avenir"),
                                                              )),
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                "No",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "Avenir"),
                                                              )),
                                                        ],
                                                      );
                                                    });
                                              },
                                              tap: () {
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    NoteEditorScreen.routeName,
                                                    arguments: e.id);
                                              },
                                            ));
                                      },
                                    ).toList(),
                                  )
                                : Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  );
                          }),
                    ],
                  )
                : Center(
                    child: Text("No items"),
                  )),
      ),
    );
  }

  void goToNotesScreen(List<Note> notes, Notes noteData, BuildContext context,
      String title) async {
    var id = notes.length.toString();
    Note createdNote = Note(
      title: title,
      content: "<h1>New Note</h1>",
      createdAt: DateFormat.yMEd().format(DateTime.now()),
      gradientColorIndex: Random().nextInt(5),
      id: getRandomString(10),
    );
    _notes = null;
    await noteData.addNote(createdNote).then((value) {
      _notes = helper.getNotes(context);
      _notes!.then((value) {
        value.forEach((element) {
          notes.add(element);
        });
      }).whenComplete(() {
        setState(() {});
      });
      Utilities.showSnackbar(context, "Created Note", Colors.lime);
    });
  }
}
