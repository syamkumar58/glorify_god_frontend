// ignore_for_file: avoid_dynamic_calls

import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleTile extends StatefulWidget {
  const TitleTile({
    super.key,
    required this.title,
    required this.onPressViewAll,
    this.showViewAll = true,
  });

  final String title;
  final bool showViewAll;
  final Function onPressViewAll;

  @override
  // ignore: library_private_types_in_public_api
  _TitleTileState createState() => _TitleTileState();
}

class _TitleTileState extends State<TitleTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AppText(
        text: widget.title,
        styles: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: widget.showViewAll
          ? Bounce(
              duration: const Duration(
                milliseconds: 50,
              ),
              onPressed: () {
                widget.onPressViewAll();
              },
              child: AppText(
                text: 'View all',
                styles: GoogleFonts.manrope(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
