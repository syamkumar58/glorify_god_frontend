import 'dart:developer';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/utils/app_colors.dart';

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
    return Container(
      margin: const EdgeInsets.only(left: 10),
      // Added due to grid view can remove this line when it comes to normal flow
      width: 150,
      // 120 for non grid view
      height: 140,
      // 160 for non grid view
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: 150, // 110 for non grid view
            height: 90, // 110 for non grid view
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.darkGreyBlue2,
              image: DecorationImage(
                image: NetworkImage(
                  widget.image,
                ),
                fit: BoxFit.fill,
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
    );
  }
}
