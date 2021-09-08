import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:html_editor_enhanced/utils/utils.dart';
import 'package:quotes/quote_model.dart';
import 'package:quotes/quotes.dart';
import 'package:flutter/material.dart';
import 'package:todo_notes_thign/Utilities/utils.dart';
import 'package:todo_notes_thign/constants/theme.dart';

class QuoteTile extends StatelessWidget {
  const QuoteTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var quote = Quotes.getRandom();
    var gradientColor = GradientTemplate
        .gradientTemplate[
            Random().nextInt(GradientTemplate.gradientTemplate.length)]
        .colors;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: '"' + quote.content + '"' + " -" + quote.author));
        Utilities.showSnackbar(context, "Copied quote", Colors.tealAccent);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColor),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '"' + quote.content + '"',
              style: TextStyle(
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Text("- " + quote.author,
                style: TextStyle(
                  fontFamily: 'Avenir',
                )),
          ],
        ),
      ),
    );
  }
}
