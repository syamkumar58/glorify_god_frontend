part of 'artists_list_cubit.dart';

@immutable
abstract class ArtistsListState {}

class ArtistsListInitial extends ArtistsListState {}

class ArtistsListLoaded extends ArtistsListState {
  ArtistsListLoaded({required this.artistsList});

  final List<ArtistsListModel> artistsList;
}
