import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:meta/meta.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'youtube_player_state.dart';

class YoutubePlayerCubit extends Cubit<YoutubePlayerState> {
  YoutubePlayerCubit() : super(YoutubePlayerInitial());

  void initialiseThePlayer() {
    emit(YoutubePlayerInitial());
  }

  YoutubePlayerController? youtubePlayerController;
  int selectedIndex = 0;

  Future start({
    required Song songData,
    required List<Song> songs,
    required int currentSongIndex,
  }) async {
    selectedIndex = currentSongIndex;

    if (youtubePlayerController != null) {
      log(
        '${songs[selectedIndex].ytUrl} 7& ${songs[selectedIndex].title}',
        name: 'Song playing dispose activated',
      );
      youtubePlayerController?.dispose();
    }

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: songs[selectedIndex].ytUrl,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: false,
      ),
    );

    //<-- Initial start to the cubit  -->/
    emit(
      YoutubePlayerInitialised(
        songs: songs,
        currentSongIndex: selectedIndex,
        youtubePlayerController: youtubePlayerController!,
        songData: songData,
      ),
    );

    //<-- once started the the listener handles the rest -->/
    youtubePlayerController?.addListener(() {
      log('handle the listener');
      emit(
        YoutubePlayerInitialised(
          songs: songs,
          currentSongIndex: selectedIndex,
          youtubePlayerController: youtubePlayerController!,
          songData: songData,
        ),
      );
    });
  }

  Future selectedOtherSong({
    required String videoId,
    required List<Song> songs,
    required Song songData,
  }) async {
    youtubePlayerController!.load(videoId);
    emit(
      YoutubePlayerInitialised(
        songs: songs,
        currentSongIndex: selectedIndex,
        youtubePlayerController: youtubePlayerController!,
        songData: songData,
      ),
    );
  }

  Future play() async {
    youtubePlayerController?.play();
  }

  Future pause() async {
    youtubePlayerController?.pause();
  }

  Future skipToNext({
    required List<Song> songs,
  }) async {
    if (selectedIndex < songs.length - 1) {
      selectedIndex++;
    } else {
      selectedIndex = 0;
    }

    youtubePlayerController?.load(songs[selectedIndex].ytUrl);
  }

  Future skipToPrevious({
    required List<Song> songs,
  }) async {
    if (selectedIndex > 0) {
      selectedIndex--;
    } else {
      selectedIndex = songs.length - 1;
    }
    youtubePlayerController?.load(songs[selectedIndex].ytUrl);
  }
}
