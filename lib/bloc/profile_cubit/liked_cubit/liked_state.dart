part of 'liked_cubit.dart';

@immutable
abstract class LikedState {}

class LikedInitial extends LikedState {}

class LikedLoaded extends LikedState {
  LikedLoaded({required this.likedSongs});

  final List<GetFavouritesModel> likedSongs;
}
