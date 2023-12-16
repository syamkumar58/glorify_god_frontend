// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
//
// MediaControl playControl = const MediaControl(
//   androidIcon: 'drawable/play_arrow',
//   label: 'Play',
//   action: MediaAction.play,
// );
// MediaControl pauseControl = const MediaControl(
//   androidIcon: 'drawable/pause',
//   label: 'Pause',
//   action: MediaAction.pause,
// );
// MediaControl skipToNextControl = const MediaControl(
//   androidIcon: 'drawable/skip_to_next',
//   label: 'Next',
//   action: MediaAction.skipToNext,
// );
// MediaControl skipToPreviousControl = const MediaControl(
//   androidIcon: 'drawable/skip_to_prev',
//   label: 'Previous',
//   action: MediaAction.skipToPrevious,
// );
// MediaControl stopControl = const MediaControl(
//   androidIcon: 'drawable/stop',
//   label: 'Stop',
//   action: MediaAction.stop,
// );
//
// class AudioPlayerTask extends BackgroundAudioTask {
//   final _que = <MediaItem>[
//     MediaItem(
//         id:
//         'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
//         album: 'Science Friday',
//         title: 'A salute to head-Scratching science',
//         duration: const Duration(milliseconds: 57398921),
//         artUri: Uri.parse(
//             'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg')),
//     MediaItem(
//         id: 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
//         album: 'Science Friday',
//         title: 'A salute to head-Scratching science',
//         duration: const Duration(milliseconds: 57398921),
//         artUri: Uri.parse(
//             'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg')),
//   ];
//
//
//   int _queIndex = -1;
//   AudioPlayer _audioPlayer = AudioPlayer();
//   late AudioProcessingState _audioProcessingState;
//   late bool isPlaying;
//
//   bool get hasNext => _queIndex + 1 > _que.length;
//   bool get hasPrevious => _queIndex > 0;
//
//   MediaItem get mediaItem => _que[_queIndex];
//
//
//
//
//   @override
//   Future<void> onStart(Map<String, dynamic>? params) {
//     return super.onStart(params);
//   }
//
//
//
//
// }
//
// class Player extends StatefulWidget {
//   const Player({Key? key}) : super(key: key);
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _PlayerState createState() => _PlayerState();
// }
//
// class _PlayerState extends State<Player> {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold();
//   }
// }
