import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerHandler extends ChangeNotifier {
  Song emptySongData = Song(
    songId: 0,
    artistUID: 0,
    videoUrl: '',
    title: '',
    artist: '',
    artUri: '',
    lyricist: '',
    ytTitle: '',
    ytUrl: '',
    ytImage: '',
    createdAt: DateTime.now(),
  );

  //<-- LandScope Mode-->/
  bool _fullScreenEnabled = false;

  bool get fullScreenEnabled => _fullScreenEnabled;

  set fullScreenEnabled(bool value) {
    _fullScreenEnabled = value;
    notifyListeners();
  }

  //<-- Extend to normal screen or minimize to short screen -->/
  bool _extendToFullScreen = false;

  bool get extendToFullScreen => _extendToFullScreen;

  set extendToFullScreen(bool value) {
    _extendToFullScreen = value;
    notifyListeners();
  }

//<-- Holding list of songs -->/
  List<Song> _selectedSongsList = [];

  List<Song> get selectedSongsList => _selectedSongsList;

  set selectedSongsList(List<Song> value) {
    _selectedSongsList = value;
    notifyListeners();
  }

  Song _selectedSongData = Song(
    songId: 0,
    artistUID: 0,
    videoUrl: '',
    title: '',
    artist: '',
    artUri: '',
    lyricist: '',
    ytTitle: '',
    ytUrl: '',
    ytImage: '',
    createdAt: DateTime.now(),
  );

//<-- Holding selected song data -->/
  Song get selectedSongData => _selectedSongData;

  set selectedSongData(Song value) {
    _selectedSongData = value;
    notifyListeners();
  }

  YoutubePlayerController? _youtubePlayerController;

  YoutubePlayerController? get youtubePlayerController =>
      _youtubePlayerController;

  set youtubePlayerController(YoutubePlayerController? value) {
    _youtubePlayerController = value;
    notifyListeners();
  }

  int selectedIndex = 0;

  Future startPlayer({
    required Song songData,
    required List<Song> songs,
    required int currentSongIndex,
  }) async {
    final gotSelectedSongsList = List<Song>.from(songs);
    selectedIndex = currentSongIndex;

    log('$currentSongIndex // $selectedIndex', name: 'selectedIndex ate ');

    selectedSongsList.clear();
    selectedSongData = emptySongData;
    selectedSongsList.addAll(gotSelectedSongsList);
    selectedSongData = songData;

    if (youtubePlayerController != null) {
      return loadSelectedSong(
        videoId: songData.ytUrl,
        currentSongIndex: selectedIndex,
      );
    }

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: songData.ytUrl,
      flags: const YoutubePlayerFlags(
        hideControls: true,
      ),
    );

    youtubePlayerController!.load(songData.ytUrl);

    youtubePlayerController!.addListener(() {
      youtubePlayerController = youtubePlayerController;
    });
  }

  void loadSelectedSong({
    required String videoId,
    required int currentSongIndex,
  }) {
    selectedIndex - currentSongIndex;
    youtubePlayerController!.load(videoId);
  }

  void resume() {
    youtubePlayerController!.play();
  }

  void pause() {
    youtubePlayerController!.pause();
  }

  Future skipToNext({required List<Song> songs}) async {
    if (selectedIndex < songs.length - 1) {
      selectedIndex++;
    } else {
      selectedIndex = 0;
    }

    youtubePlayerController!.load(songs[selectedIndex].ytUrl);
  }

  Future skipToPrevious({required List<Song> songs}) async {
    if (selectedIndex > 0) {
      selectedIndex--;
    } else {
      selectedIndex = songs.length - 1;
    }

    youtubePlayerController!.load(songs[selectedIndex].ytUrl);
  }
}
