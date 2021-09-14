import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:provider/provider.dart';
import 'package:todo_notes_thign/Utilities/utils.dart';
import 'package:todo_notes_thign/constants/delayed_anim.dart';
import 'package:todo_notes_thign/db/notes_helper.dart';
import 'package:todo_notes_thign/models/note.dart';
import 'package:todo_notes_thign/provider/note_provider.dart';
import 'package:todo_notes_thign/screens/Home.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    Key? key,
  }) : super(key: key);

  static const routeName = "/note-editor";

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen>
    with SingleTickerProviderStateMixin {
  HtmlEditorController controller = HtmlEditorController();
  String result = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  final int delayedAmount = 500;
  late double _scale;
  late AnimationController _controller;
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

    super.initState();
  }

  NotesHelper helper = NotesHelper();

  @override
  Widget build(BuildContext context) {
    String getId() {
      return ModalRoute.of(context)!.settings.arguments as String;
    }

    final id = getId();

    Future<Note> getNote() {
      return helper.getNoteById(id);
    }

    final loadedNote = getNote();
    final noteData = Provider.of<Notes>(context);

    final color = Colors.white;
    _scale = 1 - _controller.value;

    late String title;

    bool saved = false;

    return StreamBuilder(
        stream: loadedNote.asStream(),
        builder: (ctx, AsyncSnapshot<Note> snap) {
          if (snap.hasData) {
            title = snap.data == null ? "Loading" : snap.data!.title;
          } else {
            title = "Not found";
          }
          return snap.hasData
              ? Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    actions: [
                      IconButton(
                          tooltip: "Save",
                          onPressed: () async {
                            var txt = await controller.getText();
                            // if (txt.contains('src=\"data:')) {
                            //   txt =
                            //       '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                            // }
                            setState(() {
                              result = txt;
                            });

                            await noteData.saveNoteContent(result,
                                title.isEmpty ? snap.data!.title : title, id);

                            setState(() {
                              saved = true;
                            });
                            Utilities.showSnackbar(
                                context, "Saved note", Colors.green);
                          },
                          icon: Icon(Icons.save)),
                      IconButton(
                          tooltip: "Leave",
                          onPressed: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (c) => HomePage()));
                          },
                          icon: Icon(Icons.done))
                    ],
                    title: GestureDetector(
                      onTap: () {
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
                                          onPressed: () async {
                                            await noteData
                                                .saveNoteContent(
                                                    result, title, id)
                                                .then((value) async {
                                              await helper.getNotes(context);
                                            });
                                            setState(() {});

                                            Navigator.pop(context);
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
                      child: Row(
                        children: [
                          Text(
                            snap.data!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.edit),
                        ],
                      ),
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        HtmlEditor(
                          controller: controller,
                          htmlEditorOptions: HtmlEditorOptions(
                            hint: 'Your text here...',
                            initialText: snap.data!.content == ""
                                ? ""
                                : snap.data!.content,

                            shouldEnsureVisible: true,

                            //initialText: "<p>text content initial, if any</p>",
                          ),
                          htmlToolbarOptions: HtmlToolbarOptions(
                            toolbarPosition:
                                ToolbarPosition.aboveEditor, //by default
                            toolbarType:
                                ToolbarType.nativeScrollable, //by default
                            onButtonPressed: (ButtonType type, bool? status,
                                Function()? updateStatus) {
                              print(
                                  "button '${describeEnum(type)}' pressed, the current selected status is $status");
                              return true;
                            },
                            onDropdownChanged: (DropdownType type,
                                dynamic changed,
                                Function(dynamic)? updateSelectedItem) {
                              print(
                                  "dropdown '${describeEnum(type)}' changed to $changed");
                              return true;
                            },
                            mediaLinkInsertInterceptor:
                                (String url, InsertFileType type) {
                              print(url);
                              return true;
                            },
                            mediaUploadInterceptor:
                                (PlatformFile file, InsertFileType type) async {
                              print(file.name); //filename
                              print(file.size); //size in bytes
                              print(file
                                  .extension); //file extension (eg jpeg or mp4)
                              return true;
                            },
                          ),
                          otherOptions: OtherOptions(height: 550),
                          callbacks: Callbacks(
                              onBeforeCommand: (String? currentHtml) {
                            print('html before change is $currentHtml');
                          }, onChangeContent: (String? changed) {
                            print('content changed to $changed');
                            setState(() {
                              saved = false;
                            });
                          }, onChangeCodeview: (String? changed) {
                            print('code changed to $changed');
                            setState(() {
                              saved = false;
                            });
                          }, onChangeSelection: (EditorSettings settings) {
                            print(
                                'parent element is ${settings.parentElement}');
                            print('font name is ${settings.fontName}');
                          }, onDialogShown: () {
                            print('dialog shown');
                          }, onEnter: () {
                            print('enter/return pressed');
                          }, onFocus: () {
                            print('editor focused');
                          }, onBlur: () {
                            print('editor unfocused');
                          }, onBlurCodeview: () {
                            print('codeview either focused or unfocused');
                          }, onInit: () {
                            print('init');
                          },

                              //this is commented because it overrides the default Summernote handlers
                              /*onImageLinkInsert: (String? url) {
                      print(url ?? "unknown url");
                    },
                    onImageUpload: (FileUpload file) async {
                      print(file.name);
                      print(file.size);
                      print(file.type);
                      print(file.base64);
                    },*/
                              onImageUploadError: (FileUpload? file,
                                  String? base64Str, UploadError error) {
                            print(describeEnum(error));
                            print(base64Str ?? '');
                            if (file != null) {
                              print(file.name);
                              print(file.size);
                              print(file.type);
                            }
                          }, onKeyDown: (int? keyCode) {
                            print('$keyCode key downed');
                          }, onKeyUp: (int? keyCode) {
                            print('$keyCode key released');
                          }, onMouseDown: () {
                            print('mouse downed');
                          }, onMouseUp: () {
                            print('mouse released');
                          }, onPaste: () {
                            print('pasted into editor');
                          }, onScroll: () {
                            print('editor scrolled');
                          }),
                          plugins: [
                            SummernoteAtMention(
                                getSuggestionsMobile: (String value) {
                                  var mentions = <String>[
                                    'test1',
                                    'test2',
                                    'test3'
                                  ];
                                  return mentions
                                      .where(
                                          (element) => element.contains(value))
                                      .toList();
                                },
                                mentionsWeb: ['test1', 'test2', 'test3'],
                                onSelect: (String value) {
                                  print(value);
                                }),
                          ],
                        ),
                        DelayedAnimation(
                          delay: delayedAmount,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                  onPressed: () {
                                    controller.undo();
                                  },
                                  icon: Icon(
                                    Icons.undo,
                                    color: Colors.white,
                                  ),
                                  label: Text('Undo',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.redo,
                                    color: Colors.white,
                                  ),
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                  onPressed: () {
                                    controller.clear();
                                  },
                                  label: Text('Reset',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Scaffold(
                  body: Center(
                      child: Text(
                  "Loading...",
                  style: TextStyle(fontFamily: "Avenir"),
                )));
        });
  }
}
