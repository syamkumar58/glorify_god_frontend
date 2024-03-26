part of 'youtube_player_cubit.dart';

@immutable
abstract class YoutubePlayerState {}

class YoutubePlayerInitial extends YoutubePlayerState {}

class YoutubePlayerInitialised extends YoutubePlayerState {
  YoutubePlayerInitialised({
    required this.songData,
    required this.songs,
    required this.youtubePlayerController,
    required this.currentSongIndex,
  });

  final Song songData;
  final List<Song> songs;
  final YoutubePlayerController youtubePlayerController;
  final int currentSongIndex;
}

class YoutubePlayerInitialised2 extends YoutubePlayerState {
  YoutubePlayerInitialised2({
    required this.songData,
    required this.songs,
    required this.youtubePlayerController,
    required this.currentSongIndex,
  });

  final Song songData;
  final List<Song> songs;
  final YoutubePlayerController youtubePlayerController;
  final int currentSongIndex;
}
