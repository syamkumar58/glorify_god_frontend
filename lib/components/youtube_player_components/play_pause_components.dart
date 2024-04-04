import 'package:flutter/material.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/utils/app_colors.dart';

class PlayPauseControls extends StatelessWidget {
  const PlayPauseControls({
    super.key,
    required this.youtubePlayerHandler,
    required this.songs,
    required this.appState,
  });

  final YoutubePlayerHandler youtubePlayerHandler;
  final AppState appState;

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.black.withOpacity(0.7),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              youtubePlayerHandler.skipToPrevious(
                songs: songs,
                appState: appState,
              );
            },
            icon: Icon(
              Icons.skip_previous,
              size: 30,
              color: AppColors.white,
            ),
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.black.withOpacity(0.7),
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (youtubePlayerHandler
                    .youtubePlayerController!.value.isPlaying) {
                  youtubePlayerHandler.pause();
                } else {
                  youtubePlayerHandler.resume();
                }
              },
              icon: Icon(
                youtubePlayerHandler.youtubePlayerController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 30,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.black.withOpacity(0.7),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              // await skipNext();
              youtubePlayerHandler.skipToNext(
                songs: songs,
                appState: appState,
              );
            },
            icon: Icon(
              Icons.skip_next,
              size: 30,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
