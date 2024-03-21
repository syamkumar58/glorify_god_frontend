import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:meta/meta.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
      youtubePlayerController?.close();
    }

    youtubePlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
      ),
    );

    final list = songs.map((e) => e.ytUrl).toList();

    youtubePlayerController?.loadPlaylist(list: list);

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
    youtubePlayerController!.listen((event) {
      log('handle the listener ${event.playerState}');
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
    required int currentPlayingIndex,
  }) async {
    selectedIndex = currentPlayingIndex;
    youtubePlayerController?.loadVideo(videoId);
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
    youtubePlayerController?.playVideo();
  }

  Future pause() async {
    youtubePlayerController?.pauseVideo();
  }

  Future skipToNext({
    required List<Song> songs,
  }) async {
    if (selectedIndex < songs.length - 1) {
      selectedIndex++;
    } else {
      selectedIndex = 0;
    }

    final songData = songs[selectedIndex];
    youtubePlayerController?.loadVideo(songs[selectedIndex].ytUrl);
    emit(
      YoutubePlayerInitialised(
        songs: songs,
        currentSongIndex: selectedIndex,
        youtubePlayerController: youtubePlayerController!,
        songData: songData,
      ),
    );
  }

  Future skipToPrevious({
    required List<Song> songs,
  }) async {
    if (selectedIndex > 0) {
      selectedIndex--;
    } else {
      selectedIndex = songs.length - 1;
    }
    final songData = songs[selectedIndex];
    youtubePlayerController?.loadVideo(songs[selectedIndex].ytUrl);
    emit(
      YoutubePlayerInitialised(
        songs: songs,
        currentSongIndex: selectedIndex,
        youtubePlayerController: youtubePlayerController!,
        songData: songData,
      ),
    );
  }
}
