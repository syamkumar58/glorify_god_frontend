// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:glorify_god/bloc/profile_cubit/songs_info_cubit/songs_data_info_cubit.dart';
// import 'package:glorify_god/components/minimize_option.dart';
// import 'package:glorify_god/components/youtube_player_components/play_pause_components.dart';
// import 'package:glorify_god/provider/youtube_player_handler.dart';
// import 'package:glorify_god/utils/app_colors.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class YoutubePlayerWidget extends StatefulWidget {
//   const YoutubePlayerWidget({super.key, required this.youtubePlayerHandler});
//
//   final YoutubePlayerHandler youtubePlayerHandler;;
//
//   @override
//   State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
// }
//
// class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return youtubePlayerWidget();
//   }
//
//   Widget youtubePlayerWidget() {
//     return widget.youtubePlayerHandler.youtubePlayerController != null
//         ? GestureDetector(
//       onTap: _toggleControlsVisibility,
//       // youtubePlayerHandler.extendToFullScreen
//       //     ? _toggleControlsVisibility
//       //     : null,
//       onVerticalDragEnd:
//       MediaQuery.of(context).orientation == Orientation.portrait
//           ? (dragDownDetails) {
//         if (widget.youtubePlayerHandler.extendToFullScreen) {
//           widget.youtubePlayerHandler.extendToFullScreen =
//           !widget.youtubePlayerHandler.extendToFullScreen;
//         }
//       }
//           : null,
//       child: YoutubePlayerBuilder(
//         onEnterFullScreen: () {
//           // youtubePlayerHandler.fullScreenEnabled = true;
//           SystemChrome.setEnabledSystemUIMode(
//             SystemUiMode.manual,
//             overlays: [],
//           );
//         },
//         onExitFullScreen: () {
//           // youtubePlayerHandler.fullScreenEnabled = false;
//           SystemChrome.setEnabledSystemUIMode(
//             SystemUiMode.manual,
//             overlays: SystemUiOverlay.values,
//           );
//         },
//         player: YoutubePlayer(
//           controller: widget.youtubePlayerHandler.youtubePlayerController!,
//           onEnded: (metaData) {
//             SongsDataInfoCubit songsDataInfoCubit = SongsDataInfoCubit();
//             widget.youtubePlayerHandler.skipToNext(
//               songs: widget.youtubePlayerHandler.selectedSongsList,
//             );
//             songsDataInfoCubit.addSongStreamData(
//               artistId: widget.youtubePlayerHandler.selectedSongData.artistUID,
//               startDate: DateTime(DateTime.now().year, 1, 1),
//               endDate: DateTime.now(),
//             );
//           },
//           // aspectRatio: 16 / 9,
//         ),
//         builder: (context, player) {
//           log(
//             '${widget.youtubePlayerHandler.youtubePlayerController!.value.playerState}',
//             name: 'The state here',
//           );
//           final buffering = widget.youtubePlayerHandler
//               .youtubePlayerController!.value.playerState ==
//               PlayerState.buffering;
//           final unKnown = widget.youtubePlayerHandler
//               .youtubePlayerController!.value.playerState ==
//               PlayerState.unknown;
//           final unStarted = widget.youtubePlayerHandler
//               .youtubePlayerController!.value.playerState ==
//               PlayerState.unStarted;
//           return AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Stack(
//               children: [
//                 player,
//                 bufferingWidget(
//                   buffering: buffering,
//                   unKnown: unKnown,
//                   unStarted: unStarted,
//                 ),
//                 controlsWidget(
//                   buffering: buffering,
//                   unKnown: unKnown,
//                 ),
//                 //<-- Top left minimize the player option -->/
//                 if (widget.youtubePlayerHandler.extendToFullScreen &&
//                     showControls &&
//                     MediaQuery.of(context).orientation ==
//                         Orientation.portrait)
//                   Positioned(
//                     top: 20,
//                     left: 20,
//                     child: MinimizeOption(
//                       youtubePlayerHandler: widget.youtubePlayerHandler,
//                     ),
//                   ),
//                 //<-- Top right close the player option -->/
//                 Positioned(
//                   top: 20,
//                   right: 20,
//                   child: closeOption(),
//                 ),
//                 //<-- player duration text -->/
//                 if (widget.youtubePlayerHandler.extendToFullScreen &&
//                     !buffering &&
//                     !unKnown &&
//                     showControls)
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       bottom: 20,
//                       left: 12,
//                       right: 12,
//                     ),
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: durationsWithFullScreen(),
//                     ),
//                   ),
//                 //<-- Seek Bar -->/
//                 if (widget.youtubePlayerHandler.extendToFullScreen &&
//                     showControls &&
//                     !buffering &&
//                     !unKnown)
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: seekBar(),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     )
//         : const CircularProgressIndicator();
//   }
//
//   Widget bufferingWidget({
//     bool buffering = false,
//     bool unKnown = false,
//     bool unStarted = false,
//   }) {
//     return buffering || unKnown || unStarted
//         ? Center(
//       child: CircularProgressIndicator(
//         color: AppColors.white,
//       ),
//     )
//         : const SizedBox.shrink();
//   }
//
//   Widget controlsWidget({
//     bool buffering = false,
//     bool unKnown = false,
//   }) {
//     return widget.youtubePlayerHandler.extendToFullScreen &&
//         !buffering &&
//         !unKnown &&
//         showControls
//         ? Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: AppColors.black.withOpacity(0.5),
//       ),
//       child: Center(
//         child: PlayPauseControls(
//           youtubePlayerHandler: youtubePlayerHandler,
//           songs: widget.songs,
//         ),
//       ),
//     )
//         : !youtubePlayerHandler.extendToFullScreen && showControls
//         ? Align(
//       alignment: Alignment.centerRight,
//       child: MinimizedScreenOverLay(
//         youtubePlayerHandler: youtubePlayerHandler,
//       ),
//     )
//         : const SizedBox();
//   }
//
//
//   Widget closeOption() {
//     return youtubePlayerHandler.extendToFullScreen &&
//         showControls &&
//         MediaQuery.of(context).orientation == Orientation.portrait
//         ? CloseOption(
//       onPressed: () {
//         youtubePlayerHandler.clearStoredData();
//         youtubePlayerHandler.extendToFullScreen = false;
//         if (youtubePlayerHandler.youtubePlayerController != null) {
//           youtubePlayerHandler.youtubePlayerController = null;
//           youtubePlayerHandler.youtubePlayerController!.dispose();
//         }
//       },
//     )
//         : const SizedBox();
//   }
//
//   Widget durationsWithFullScreen() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         AppText(
//           text:
//           '${youtubePlayerHandler.youtubePlayerController!.value.position.inMinutes.toString().padLeft(2, '0')}:${(youtubePlayerHandler.youtubePlayerController!.value.position.inSeconds % 60).toString().padLeft(
//             2,
//             '0',
//           )}'
//               ' / ${youtubePlayerHandler.youtubePlayerController!.metadata.duration.inMinutes.toString().padLeft(
//             2,
//             '0',
//           )}:${(youtubePlayerHandler.youtubePlayerController!.metadata.duration.inSeconds % 60).toString().padLeft(
//             2,
//             '0',
//           )}',
//           styles: GoogleFonts.manrope(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//             color: AppColors.white,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 0),
//           child: Bounce(
//             duration: const Duration(milliseconds: 50),
//             onPressed: () {
//               log(
//                 '${MediaQuery.of(context).orientation == Orientation.portrait}',
//                 name: 'The orientation',
//               );
//               changeOrientation();
//             },
//             child: Icon(
//               MediaQuery.of(context).orientation == Orientation.portrait
//                   ? Icons.fullscreen
//                   : Icons.fullscreen_exit,
//               size: 22,
//               color: AppColors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget seekBar() {
//     return pb.ProgressBar(
//       bufferedBarColor: AppColors.dullWhite,
//       thumbCanPaintOutsideBar: false,
//       progressBarColor: AppColors.redAccent,
//       thumbColor: AppColors.redAccent.withOpacity(0.5),
//       barCapShape: pb.BarCapShape.square,
//       thumbRadius: 8,
//       thumbGlowRadius: 10,
//       buffered: Duration(
//         seconds: youtubePlayerHandler
//             .youtubePlayerController!.value.position.inSeconds +
//             50,
//       ),
//       progress: Duration(
//         seconds: youtubePlayerHandler
//             .youtubePlayerController!.value.position.inSeconds,
//       ),
//       total: Duration(
//         seconds: youtubePlayerHandler
//             .youtubePlayerController!.metadata.duration.inSeconds,
//       ),
//       timeLabelTextStyle: const TextStyle(
//         color: Colors.transparent,
//         fontSize: 0,
//       ),
//       onSeek: (duration) {
//         youtubePlayerHandler.youtubePlayerController!.seekTo(duration);
//       },
//     );
//   }
//
// }
//
