import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/song_models/artists_song_data_by_id.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:meta/meta.dart';

part 'songs_data_info_state.dart';

class SongsDataInfoCubit extends Cubit<SongsDataInfoState> {
  SongsDataInfoCubit() : super(SongsDataInfoInitial());

  Future addSongStreamData(
      {required int artistId,
      required DateTime startDate,
      required DateTime endDate,}) async {
    final res = await ApiCalls().createArtistsSongData(
      artistId: artistId,
      createdAt: DateTime.now(),
    );

    if (res.statusCode == 200) {
      getData(
        artistId: artistId,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      log('${res.statusCode}', name: 'addSongStreamData failed from cubit');
    }
  }

  Future getData(
      {required int artistId,
      required DateTime startDate,
      required DateTime endDate,}) async {
    final data = await ApiCalls().getArtistsSongDataById(
      artistId: artistId,
      startDate: startDate,
      endDate: endDate,
    );

    log(data.body, name: 'The Data');

    if (data.statusCode == 200) {
      final songsInformation = getArtistSongsDataByIdModelFromJson(data.body);
      log('${songsInformation.totalStreamCount}',
          name: 'songs onfo from cubit',);
      emit(SongsDataInfoLoaded(
        songsInformation: songsInformation.data,
        totalStreamCount: songsInformation.totalStreamCount,
        monetization: songsInformation.monetization,
        streamsCompletedAfterMonetization:
            songsInformation.streamsCompletedAfterMonetization,
      ),);
    } else {
      emit(SongsDataInfoLoaded(
        songsInformation: const [],
        totalStreamCount: 0,
        monetization: false,
        streamsCompletedAfterMonetization: 0,
      ),);
    }
  }
}
