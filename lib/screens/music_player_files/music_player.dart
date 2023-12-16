// import 'dart:ui';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:christian_songs/components/noisey_text.dart';
// import 'package:christian_songs/config/helpers.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bounce/flutter_bounce.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:just_audio/just_audio.dart';
//
// class MusicPlayerScreen extends StatefulWidget {
//   const MusicPlayerScreen({Key? key}) : super(key: key);
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
// }
//
// class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
//   double get width => MediaQuery.of(context).size.width;
//
//   double get height => MediaQuery.of(context).size.height;
//   AudioPlayer player = AudioPlayer();
//   String audioUrl =
//       'https://storage.googleapis.com/heartintune-qa-storage/MeditateNow/audios/english/15Min-Checkat7min.m4a';
//   String backGroundImage =
//       'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png';
//   Duration totalSongDuration = Duration.zero;
//   Duration currentPositionOfSong = Duration.zero;
//   late PlayerState playerState;
//
//   bool isPlaying = false;
//   bool started = false;
//   bool isFav = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initialSetUp();
//   }
//
//   Future initialSetUp() async {
//     final result = await player.play(audioUrl);
//     if (result > 0) {
//       setState(() {
//         isPlaying = true;
//         started = true;
//       });
//     }
//
//     await playerSetup();
//   }
//
//   Future playerSetup() async {
//     player.onPlayerStateChanged.listen((playerState) {
//       setState(() {
//         this.playerState = playerState;
//         isPlaying = playerState == PlayerState.PLAYING;
//       });
//     });
//
//     player.onDurationChanged.listen((event) {
//       setState(() {
//         totalSongDuration = event;
//       });
//     });
//
//     player.onAudioPositionChanged.listen((event) {
//       setState(() {
//         currentPositionOfSong = event;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       extendBodyBehindAppBar: true,
//       appBar: appBar(),
//       body: mainBody(),
//       floatingActionButton: floatingFavButton(),
//     );
//   }
//
//   Widget mainBody() {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//           image: DecorationImage(
//         fit: BoxFit.cover,
//         image: NetworkImage(
//           backGroundImage,
//         ),
//       )),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(
//           sigmaX: 5,
//           sigmaY: 5,
//         ),
//         child: Container(
//           decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 playerUi(),
//                 playerControls(),
//                 seekBar(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   AppBar appBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: IconButton(
//           onPressed: () {},
//           icon: const Icon(
//             Icons.keyboard_arrow_left,
//             size: 40,
//           )),
//     );
//   }
//
//   Widget playerUi() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.only(top: height * 0.06, bottom: height * 0.04),
//         child: Card(
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Container(
//             width: 300,
//             height: 300,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: NetworkImage(
//                     backGroundImage,
//                   ),
//                 )),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget playerControls() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: width * 0.15, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//       ),
//       child: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             backwardButton(),
//             playPauseButton(),
//             forwardButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget backwardButton() {
//     return CupertinoButton(
//       onPressed: currentPositionOfSong.inSeconds > 5
//           ? () {
//               if (currentPositionOfSong.inSeconds > 5) {
//                 player.seek(
//                     Duration(seconds: currentPositionOfSong.inSeconds - 5));
//               }
//             }
//           : null,
//       child: Icon(
//         Icons.fast_rewind,
//         size: 35,
//         color: currentPositionOfSong.inSeconds > 5
//             ? Colors.white
//             : Colors.grey[600],
//       ),
//     );
//   }
//
//   Widget playPauseButton() {
//     return Bounce(
//       onPressed: () async {
//         if (isPlaying) {
//           await player.pause();
//         } else {
//           await player.resume();
//         }
//       },
//       duration: const Duration(milliseconds: 150),
//       child: Icon(
//         isPlaying ? Icons.pause_circle : Icons.play_circle,
//         color: Colors.white,
//         size: 60,
//       ),
//     );
//   }
//
//   Widget forwardButton() {
//     return CupertinoButton(
//       child: const Icon(
//         Icons.fast_forward,
//         size: 35,
//         color: Colors.white,
//       ),
//       onPressed: () {
//         player.seek(Duration(seconds: currentPositionOfSong.inSeconds + 5));
//       },
//     );
//   }
//
//   Widget seekBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       child: Column(
//         children: [
//           SliderTheme(
//             data: const SliderThemeData(
//               trackHeight: 6,
//             ),
//             child: Slider(
//                 min: 0,
//                 max: totalSongDuration.inSeconds.toDouble(),
//                 value: currentPositionOfSong.inSeconds.toDouble(),
//                 inactiveColor: Colors.grey[600],
//                 activeColor: Colors.white,
//                 onChanged: (value) {
//                   final finalPosition = Duration(seconds: value.toInt());
//                   player.seek(finalPosition);
//                 }),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//               left: 12,
//               right: 12,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 noiseyText(convertDurations(currentPositionOfSong),
//                     styles: GoogleFonts.manrope(
//                       color: Colors.white,
//                     )),
//                 noiseyText(convertDurations(totalSongDuration),
//                     styles: GoogleFonts.manrope(
//                       color: Colors.white,
//                     )),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget floatingFavButton() {
//     return Padding(
//       padding: const EdgeInsets.only(right: 20, bottom: 20),
//       child: Bounce(
//           duration: const Duration(milliseconds: 150),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.blueGrey.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.grey.shade500,
//                     blurRadius: 2,
//                     spreadRadius: 0.8,
//                     offset: const Offset(1, 1)),
//                 const BoxShadow(
//                     color: Colors.white,
//                     blurRadius: 2,
//                     spreadRadius: 0.8,
//                     offset: Offset(-1, -1)),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Icon(
//                 isFav ? Icons.favorite : Icons.favorite_border_outlined,
//                 color: isFav ? Colors.red : Colors.grey.shade700,
//                 size: 30,
//               ),
//             ),
//           ),
//           onPressed: () {
//             setState(() {
//               isFav = !isFav;
//             });
//           }),
//     );
//   }
//
//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }
// }
