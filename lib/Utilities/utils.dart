import 'package:flutter/material.dart';

class Utilities {
  static void showSnackbar(BuildContext context, String content, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
      backgroundColor: color == null ? null : color,
    ));
  }
}
