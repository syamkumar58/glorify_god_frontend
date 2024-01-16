import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  const YoutubeVideoPlayerScreen({super.key});

  @override
  State<YoutubeVideoPlayerScreen> createState() => _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  YoutubePlayerController ytController = YoutubePlayerController(
    initialVideoId: '9qegZD84aCw',
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: ytController,
      width: width,
    );
  }
}
