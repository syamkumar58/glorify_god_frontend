import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/profile_bloc/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit({required this.songsDataInfoCubit, required this.appState})
      : super(VideoPlayerInitial());

  final AppState appState;

  final SongsDataInfoCubit songsDataInfoCubit;

  Future setToInitialState() async {
    emit(VideoPlayerInitial());
  }

  ChewieController? playerController;
  VideoPlayerController? videoPlayerController;
  int currentSongIndex = 0;

  Future startPlayer({
    required Song songData,
    required List<Song> songs,
    required int selectedSongIndex,
  }) async {
    currentSongIndex = selectedSongIndex;

    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }

    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        songData.videoUrl,
      ),
    );

    playerController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      showControls: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.white,
        handleColor: Colors.transparent,
      ),
    );

    playerController!.videoPlayerController.addListener(() {
      emit(VideoPlayerInitialised(
        songData: songData,
        songs: songs,
        chewieController: playerController!,
        currentSongIndex: currentSongIndex,
      ));

      log('${playerController!.videoPlayerController.value.position} // ${playerController!.videoPlayerController.value.duration}'
          '\n1.${playerController!.videoPlayerController.value.position != Duration.zero}'
          '\n2.${playerController!.videoPlayerController.value.position >= playerController!.videoPlayerController.value.duration}',
          name:'The nme from the cubit');

      if (playerController!.videoPlayerController.value.position !=
              Duration.zero &&
          playerController!.videoPlayerController.value.position >=
              playerController!.videoPlayerController.value.duration) {
        log('message 12345');
        songsDataInfoCubit.addSongStreamData(artistId: songData.artistUID);
        setToInitialState();
        skipToNext(songs: songs);
      }
    });

    log('call happened here for checking the favs ${songData.songId}');
    appState.checkFavourites(songId: songData.songId);
    // await BlocProvider.of<SongFavouriteCubit>(context)
    //     .checkSongFavourite(songId: songData.songId);
  }

  Future resume() async {
    playerController!.play();
  }

  Future pause() async {
    playerController!.pause();
  }

  Future skipToNext({
    required List<Song> songs,
  }) async {
    if (currentSongIndex < songs.length - 1) {
      currentSongIndex++;
    } else {
      currentSongIndex = 0;
    }

    final songData = songs[currentSongIndex];

    startPlayer(
        songData: songData, songs: songs, selectedSongIndex: currentSongIndex);
  }

  Future skipToPrevious({
    required List<Song> songs,
  }) async {
    if (currentSongIndex > 0) {
      currentSongIndex--;
    } else {
      currentSongIndex = songs.length - 1;
    }

    final songData = songs[currentSongIndex];

    startPlayer(
        songData: songData, songs: songs, selectedSongIndex: currentSongIndex);
  }

  Future stopVideoPlayer() async {
    if (playerController!.videoPlayerController.value.isInitialized) {
      videoPlayerController!.dispose();
      playerController!.dispose();
    }

    await setToInitialState();
  }
}
