import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:meta/meta.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

part 'youtube_player_state.dart';

class YoutubePlayerCubit extends Cubit<YoutubePlayerState> {
  YoutubePlayerCubit({required this.appState}) : super(YoutubePlayerInitial());

  final AppState appState;

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

  Future startPlayer({
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
      youtubePlayerController!.close();
    }

    youtubePlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
        showControls:false,
        showVideoAnnotations: false,
        loop: true,
        strictRelatedVideos: false,
        enableCaption: false,
        enableKeyboard: false,
        enableJavaScript: true,
        playsInline: false,
        showFullscreenButton: false,
        pointerEvents: PointerEvents.none,
        origin: '',
        userAgent: '',
        captionLanguage: '',
        interfaceLanguage: '',
      ),
    );

    final list = songs.map((e) => e.ytUrl).toList();

    youtubePlayerController!.loadPlaylist(list: list);

    emit(
      YoutubePlayerInitialised2(
        songData: songData,
        songs: songs,
        currentSongIndex: selectedIndex,
        youtubePlayerController: youtubePlayerController!,
      ),
    );
  }

  Future seek({required double seconds}) async {
    youtubePlayerController!.seekTo(seconds: seconds);
  }
}
