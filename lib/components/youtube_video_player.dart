// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class YoutubeVideoPlayerScreen extends StatefulWidget {
//   const YoutubeVideoPlayerScreen({super.key});
//
//   @override
//   State<YoutubeVideoPlayerScreen> createState() =>
//       _YoutubeVideoPlayerScreenState();
// }
//
// class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
//   double get width => MediaQuery.of(context).size.width;
//
//   double get height => MediaQuery.of(context).size.height;
//   late YoutubePlayerController ytController;
//
//   @override
//   void initState() {
//     ytController = YoutubePlayerController(
//       initialVideoId: 'g1KiQRqfhNc', //'9qegZD84aCw',
//       flags: const YoutubePlayerFlags(
//         autoPlay: false,
//         mute: false,
//       ),
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: AspectRatio(
//         aspectRatio: 16 / 9,
//         child: YoutubePlayer(
//           controller: ytController,
//           width: width,
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     ytController.dispose();
//     super.dispose();
//   }
// }
