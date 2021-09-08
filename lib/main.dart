//@dart = 2.9

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_notes_thign/provider/note_provider.dart';
import 'package:todo_notes_thign/screens/Home.dart';
import 'package:todo_notes_thign/screens/note_editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Notes(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark()
            .copyWith(visualDensity: VisualDensity.adaptivePlatformDensity),
        home: HomePage(),
        routes: {
          NoteEditorScreen.routeName: (ctx) => NoteEditorScreen(),
        },
      ),
    );
  }
}
