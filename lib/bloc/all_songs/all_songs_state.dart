part of 'all_songs_cubit.dart';

@immutable
abstract class AllSongsState {}

class AllSongsInitial extends AllSongsState {}

class AllSongsLoaded extends AllSongsState {
  AllSongsLoaded({required this.songs});

  final List<GetArtistsWithSongs> songs;
}

class AllSongsHasError extends AllSongsState {
  AllSongsHasError({required this.error});

  final String error;
}
