import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/song_models/artists_song_data_by_id.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:meta/meta.dart';

part 'songs_data_info_state.dart';

class SongsDataInfoCubit extends Cubit<SongsDataInfoState> {
  SongsDataInfoCubit() : super(SongsDataInfoInitial());

  Future addSongStreamData({required int artistId}) async {
    final res = await ApiCalls().createArtistsSongData(
      artistId: artistId,
      createdAt: DateTime.now(),
    );

    if (res.statusCode == 200) {
      getData(artistId: artistId);
    } else {
      log('${res.statusCode}', name: 'addSongStreamData failed from cubit');
    }
  }

  Future getData({required int artistId}) async {
    final data = await ApiCalls().getArtistsSongDataById(
      artistId: artistId,
      startDate: DateTime(DateTime
          .now()
          .year, 1, 1),
      endDate: DateTime.now(),
    );

    log(data.body, name: 'The Data');

    if (data.statusCode == 200) {
      final songsInformation = getArtistSongsDataByIdModelFromJson(data.body);
      log('${songsInformation.totalStreamCount}',
          name: 'songs onfo from cubit');
      emit(SongsDataInfoLoaded(
        songsInformation: songsInformation.data,
        totalStreamCount: songsInformation.totalStreamCount,
      ));
    } else {
      emit(SongsDataInfoLoaded(
        songsInformation: const [],
        totalStreamCount: 0,
      ));
    }
  }

  Future getDayData(
      {required int artistId}) async {
    final data = await ApiCalls().getArtistsSongDataById(
      artistId: artistId,
      startDate: DateTime(DateTime
          .now()
          .year, 1, 1),
      endDate: DateTime.now(),
    );

    log(data.body, name: 'The Data');

    if (data.statusCode == 200) {
      final songsInformation = getArtistSongsDataByIdModelFromJson(data.body);
      log('${songsInformation.totalStreamCount}',
          name: 'songs onfo from cubit');
      emit(SongsDataInfoLoaded(
        songsInformation: songsInformation.data,
        totalStreamCount: songsInformation.totalStreamCount,
      ));
    } else {
      emit(SongsDataInfoLoaded(
        songsInformation: const [],
        totalStreamCount: 0,
      ));
    }
  }

}
