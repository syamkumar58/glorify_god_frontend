import 'dart:developer';

import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';

class SongCard extends StatefulWidget {
  const SongCard({super.key, required this.image, required this.title});

  final String image;
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _SongCardState createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
      child: SizedBox(
        width: 120,
        height: 160,
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.image,
                  ),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    log(
                      'er - $error\n st - $stackTrace',
                      name: 'Error and stack trace for image',
                    );
                  },
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.play_circle,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            AppText(
              styles: const TextStyle(fontSize: 16),
              text: widget.title,
            ),
          ],
        ),
      ),
    );
  }
}
