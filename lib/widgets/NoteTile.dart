import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:todo_notes_thign/constants/theme.dart';
import 'package:todo_notes_thign/screens/note_editor_screen.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String content;
  final String createdAt;
  final String id;
  final int gradientColorIndex;
  final List<Color> gradientColor;
  final Function deleteNote;
  final Function tap;
  const NoteTile(
      {Key? key,
      required this.title,
      required this.content,
      required this.createdAt,
      required this.gradientColorIndex,
      required this.id,
      required this.gradientColor,
      required this.deleteNote,
      required this.tap})
      : super(key: key);

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColor,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColor.last.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(4, 4),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  createdAt,
                  style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Avenir',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.white,
                  onPressed: () {
                    deleteNote();
                  },
                ),
              ],
            ),
            Text(
              parseHtmlString(content) == ""
                  ? "Click to see note"
                  : parseHtmlString(content),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
