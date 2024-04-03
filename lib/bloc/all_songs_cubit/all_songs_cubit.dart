import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/song_models/artist_with_songs_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:meta/meta.dart';

part 'all_songs_state.dart';

class AllSongsCubit extends Cubit<AllSongsState> {
  AllSongsCubit({required this.appState}) : super(AllSongsInitial());

  final AppState appState;

  Future getAllSongs({required List<int> selectedList}) async {
    try {
      final allSongs =
          await appState.getAllArtistsWithSongs(selectedList: selectedList);
      emit(AllSongsLoaded(songs: allSongs ?? []));
    } catch (er) {
      log('$er', name: 'getAllSongs error from cubit');
      if (er.toString().contains('Null check operator used on a null value')) {
        emit(
          AllSongsHasError(
            error: 'Null check operator used on a null value',
          ),
        );
      }
    }
  }
}
