part of 'songs_data_info_cubit.dart';

@immutable
abstract class SongsDataInfoState {}

class SongsDataInfoInitial extends SongsDataInfoState {}

class SongsDataInfoLoaded extends SongsDataInfoState {
  SongsDataInfoLoaded({required this.totalStreamCount,required this.songsInformation});

  final List<Datum> songsInformation;
  final int totalStreamCount;
}
