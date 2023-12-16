import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';


class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.styles,
    this.textOverflow = TextOverflow.ellipsis,
    this.maxLines = 2,
    this.textAlign = TextAlign.center,
    required this.text,
  });

  final String text;
  final TextStyle styles;
  final TextOverflow textOverflow; // = TextOverflow.ellipsis,
  final int maxLines; // = 2,
  final TextAlign textAlign; //= TextAlign.center,

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      overflow: textOverflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style: styles,
    );
  }
}
