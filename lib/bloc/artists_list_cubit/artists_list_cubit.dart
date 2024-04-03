import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/artists_model/artists_list_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:meta/meta.dart';

part 'artists_list_state.dart';

class ArtistsListCubit extends Cubit<ArtistsListState> {
  ArtistsListCubit() : super(ArtistsListInitial());

  Future getArtistsList() async {
    final list = await ApiCalls().getAllArtists();

    emit(ArtistsListLoaded(artistsList: list));
  }
}
