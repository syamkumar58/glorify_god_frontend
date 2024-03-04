import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'youtube_player_state.dart';

class YoutubePlayerCubit extends Cubit<YoutubePlayerState> {
  YoutubePlayerCubit() : super(YoutubePlayerInitial());

  YoutubePlayerController? youtubePlayerController;
  int selectedIndex = 0;

  Future start({
    // required Song songData,
    // required List<Song> songs,
    required List<String> songs,
    required int currentSongIndex,
  }) async {
    selectedIndex = currentSongIndex;

    if (youtubePlayerController != null) {
      youtubePlayerController?.dispose();
    }

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: songs[selectedIndex],
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true,
      ),
    );

    //<-- Initial start to the cubit  -->/
    emit(YoutubePlayerInitialised(
      songs: songs,
      currentSongIndex: selectedIndex,
      youtubePlayerController: youtubePlayerController!,
    ));

    //<-- once started the the listener handles the rest -->/
    youtubePlayerController?.addListener(() {
      emit(YoutubePlayerInitialised(
        songs: songs,
        currentSongIndex: selectedIndex,
        youtubePlayerController: youtubePlayerController!,
      ));
    });
  }

  Future play() async {
    youtubePlayerController?.play();
  }

  Future pause() async {
    youtubePlayerController?.pause();
  }

  Future skipToNext({
    required List<String> songs,
  }) async {
    if (selectedIndex < songs.length - 1) {
      selectedIndex++;
    } else {
      selectedIndex = 0;
    }

    youtubePlayerController?.load(songs[selectedIndex]);
  }

  Future skipToPrevious({
    required List<String> songs,
  }) async {
    if (selectedIndex > 0) {
      selectedIndex--;
    } else {
      selectedIndex = songs.length - 1;
    }
    youtubePlayerController?.load(songs[selectedIndex]);
  }
}
