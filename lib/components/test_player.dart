import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TestPlayer extends StatefulWidget {
  const TestPlayer({super.key, required this.youtubePlayerController});

  final YoutubePlayerController youtubePlayerController;

  @override
  State<TestPlayer> createState() => _TestPlayerState();
}

class _TestPlayerState extends State<TestPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: YoutubePlayer(
        controller: widget.youtubePlayerController,
        // width: width,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
