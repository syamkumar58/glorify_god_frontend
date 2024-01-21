// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
//
// class PlayerScreen extends StatefulWidget {
//   const PlayerScreen({super.key, required this.songs});
//
//   final List<Song> songs;
//
//   @override
//   State<PlayerScreen> createState() => _PlayerScreenState();
// }
//
// class _PlayerScreenState extends State<PlayerScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () async {
//               await AudioService.start(
//                 backgroundTaskEntrypoint: () {
//                   myAudioHandler(songs: widget.songs);
//                 },
//                 androidNotificationChannelName: 'Audio playback',
//               );
//             },
//             child: const Text("Play from 1st song"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await AudioService.skipToNext();
//             },
//             child: const Text("Play Next"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await AudioService.skipToPrevious();
//             },
//             child: const Text("Play Previous"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await AudioService.play();
//             },
//             child: const Text("Play"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await AudioService.pause();
//             },
//             child: const Text("Pause"),
//           ),
//           // Slider(
//           //     min: 0,
//           //     value: position.inSeconds.toDouble(),
//           //     max: position > duration ? 0 : duration.inSeconds.toDouble(),
//           //     onChanged: (value) {
//           //       setState(() {
//           //         final newPosition = Duration(seconds: value.toInt());
//           //         audioPlayer.seek(newPosition);
//           //       });
//           //     }),
//           // Text(
//           //   widget.songs[currentIndex].title,
//           //   style: const TextStyle(
//           //     fontSize: 40,
//           //   ),
//           // ),
//           // Text(
//           //   '${position.inMinutes}:${position.inSeconds}   -   ${duration.inMinutes}:${duration.inSeconds}',
//           //   style: const TextStyle(
//           //     fontSize: 24,
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
//
// Future myAudioHandler({required List<Song> songs}) async {
//   await AudioServiceBackground.run(
//       () => AudioBackgroundPlayerTask(songs: songs));
// }
