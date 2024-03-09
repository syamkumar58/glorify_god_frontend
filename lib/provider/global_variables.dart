import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';

class GlobalVariables extends ChangeNotifier {
  bool _onLogoutLoading = false;

  bool get onLogoutLoading => _onLogoutLoading;

  set onLogoutLoading(bool value) {
    _onLogoutLoading = value;
    notifyListeners();
  }

  bool _checkFavourites = true;

  bool get checkFavourites => _checkFavourites;

  set checkFavourites(bool value) {
    _checkFavourites = value;
    notifyListeners();
  }

  StreamController<ControllerWithSongData> _songStreamController =
      StreamController<ControllerWithSongData>.broadcast();

  StreamController<ControllerWithSongData> get songStreamController =>
      _songStreamController;

  set songStreamController(StreamController<ControllerWithSongData> value) {
    _songStreamController = value;
    notifyListeners();
  }
}

class ControllerWithSongData {
  ControllerWithSongData({
    required this.songs,
    required this.chewieController,
    required this.songData,
  });

  final ChewieController chewieController;
  final Song songData;
  final List<Song> songs;
}
