import 'package:flutter/material.dart';

class TextWithIcon extends StatefulWidget {
  TextWithIcon({super.key, required this.icon, required this.text});

  String text;
  IconData icon;

  @override
  State<TextWithIcon> createState() => _TextWithIcon();
}

class _TextWithIcon extends State<TextWithIcon> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(widget.icon, size: 50), Text(widget.text)],
    );
  }
}
