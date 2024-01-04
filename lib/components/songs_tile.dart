import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/components/song_image_box.dart';
import 'package:flutter/material.dart';

class SongsLikesTile extends StatefulWidget {
  const SongsLikesTile({
    super.key,
    required this.index,
    required this.songTitle,
    required this.artistName,
    required this.artUri,
  });

  final int index;
  final String songTitle;
  final String artistName;
  final String artUri;

  @override
  // ignore: library_private_types_in_public_api
  _SongsLikesTileState createState() => _SongsLikesTileState();
}

class _SongsLikesTileState extends State<SongsLikesTile> {
  double get width => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(right: 12),
      leading: SizedBox(
        width: 80,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppText(
              text: '${widget.index}.',
              styles: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SongImageBox(imageUrl: widget.artUri),
          ],
        ),
      ),
      title: AppText(
        text: widget.songTitle,
        textAlign: TextAlign.start,
        styles: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      subtitle: Row(
        children: [
          AppText(
            text: widget.artistName,
            styles: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Center(
          child: Icon(
            Icons.play_arrow,
            size: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
