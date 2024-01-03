// ignore_for_file: avoid_dynamic_calls

import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

CupertinoButton loginButton({
  double width = 2,
  double height = 2,
  Color boxColor = Colors.transparent,
  required String title,
  double fontSize = 2,
  FontWeight fontWeight = FontWeight.w400,
  Color textColor = Colors.white,
  required String backgroundImage,
  required Function onPressed,
}) {
  return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        onPressed();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: boxColor, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(
                backgroundImage,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            AppText(
              text: title,
              styles: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ],
        ),
      ));
}
